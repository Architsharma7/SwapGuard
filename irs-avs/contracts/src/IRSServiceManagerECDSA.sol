// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@eigenlayer-middleware/src/unaudited/ECDSAServiceManagerBase.sol";
import "@eigenlayer-middleware/src/unaudited/ECDSAStakeRegistry.sol";
import {Pausable} from "@eigenlayer/contracts/permissions/Pausable.sol";
import {OperatorAllowlist} from "./OperatorAllowlist.sol";
import {ECDSAUpgradeable} from "@openzeppelin-upgrades/contracts/utils/cryptography/ECDSAUpgradeable.sol";

contract IRSServiceManager is
    ECDSAServiceManagerBase,
    Pausable,
    OperatorAllowlist
{
    using ECDSAUpgradeable for bytes32;

    enum TaskType {
        SWAP_VALIDATION,
        RATE_AND_SETTLEMENT
    }

    struct Task {
        uint32 taskCreatedBlock;
        TaskType taskType;
        bytes payload;
    }

    struct Swap {
        address owner;
        uint256 notionalAmount;
        uint256 fixedRate; // In basis points (1% = 100)
        bool isPayingFixed;
        uint256 margin;
        uint256 startTime;
        uint256 duration;
        uint256 lastSettlement;
        bool isActive;
        bool matched;
        uint256 matchedWith;
    }

    error InsufficientMargin();
    error InvalidTask();
    error PaymentFailed();
    error InvalidSignature();

    uint256 public constant INITIAL_MARGIN_PERCENTAGE = 10_00; // 10%
    uint256 public constant BASIS_POINTS_DIVISOR = 10000;
    uint256 public constant SETTLEMENT_PERIOD = 30 days;

    uint32 public latestTaskNum;
    mapping(uint32 => bytes32) public allTaskHashes;
    mapping(address => mapping(uint32 => bytes)) public allTaskResponses;
    mapping(uint256 => Swap) public swaps;
    uint256 public nextSwapId;

    event NewTaskCreated(uint32 indexed taskIndex, Task task);
    event TaskResponded(uint32 indexed taskIndex, Task task, address operator);

    event SwapCreated(
        uint256 indexed swapId,
        address indexed owner,
        uint256 notionalAmount,
        uint256 fixedRate,
        bool isPayingFixed,
        uint256 margin
    );

    event SwapsMatched(uint256 indexed swap1Id, uint256 indexed swap2Id);

    event SwapSettled(
        uint256 indexed swapId,
        uint256 variableRate,
        uint256 payment,
        address indexed payer,
        address indexed receiver
    );

    constructor(
        address __avsDirectory,
        address __stakeRegistry,
        address __delegationManager
    )
        ECDSAServiceManagerBase(
            __avsDirectory,
            __stakeRegistry,
            address(0),
            __delegationManager
        )
    {}

    function initialize(
        address initialOwner_,
        address rewardsInitiator_,
        address allowlistManager_
    ) external initializer {
        __ServiceManagerBase_init(initialOwner_, rewardsInitiator_);
        __OperatorAllowlist_init(allowlistManager_, true);
    }

    modifier onlyOperator() {
        require(
            ECDSAStakeRegistry(stakeRegistry).operatorRegistered(msg.sender),
            "Operator must be the caller"
        );
        _;
    }

    function createNewTask(
        TaskType taskType,
        bytes calldata payload
    ) external payable whenNotPaused {
        if (taskType == TaskType.SWAP_VALIDATION) {
            (address user, uint256 notionalAmount, , , , ) = abi.decode(
                payload,
                (address, uint256, uint256, bool, uint256, uint256)
            );

            uint256 requiredMargin = (notionalAmount *
                INITIAL_MARGIN_PERCENTAGE) / BASIS_POINTS_DIVISOR;
            if (msg.value < requiredMargin) revert InsufficientMargin();
        }

        Task memory newTask = Task({
            taskCreatedBlock: uint32(block.number),
            taskType: taskType,
            payload: payload
        });

        allTaskHashes[latestTaskNum] = keccak256(abi.encode(newTask));

        emit NewTaskCreated(latestTaskNum++, newTask);
    }

    function respondToTask(
        Task calldata task,
        uint32 referenceTaskIndex,
        bytes calldata signature
    ) external onlyOperator {
        require(
            keccak256(abi.encode(task)) == allTaskHashes[referenceTaskIndex],
            "Invalid task"
        );

        bytes32 messageHash = keccak256(
            abi.encodePacked(
                task.taskCreatedBlock,
                uint8(task.taskType),
                task.payload
            )
        );
        bytes32 ethSignedMessageHash = messageHash.toEthSignedMessageHash();
        require(
            ethSignedMessageHash.recover(signature) == msg.sender,
            "Invalid signature"
        );

        allTaskResponses[msg.sender][referenceTaskIndex] = signature;

        if (task.taskType == TaskType.SWAP_VALIDATION) {
            processSwapValidation(task.payload);
        } else {
            processRateAndSettlement(task.payload);
        }

        emit TaskResponded(referenceTaskIndex, task, msg.sender);
    }

    function processSwapValidation(bytes memory data) internal {
        (
            address owner,
            uint256 notionalAmount,
            uint256 fixedRate,
            bool isPayingFixed,
            uint256 margin,
            uint256 duration,
            uint256 matchedWithId
        ) = abi.decode(
                data,
                (address, uint256, uint256, bool, uint256, uint256, uint256)
            );

        uint256 swapId = nextSwapId++;

        swaps[swapId] = Swap({
            owner: owner,
            notionalAmount: notionalAmount,
            fixedRate: fixedRate,
            isPayingFixed: isPayingFixed,
            margin: margin,
            startTime: block.timestamp,
            duration: duration,
            lastSettlement: block.timestamp,
            isActive: true,
            matched: matchedWithId != 0,
            matchedWith: matchedWithId
        });

        emit SwapCreated(
            swapId,
            owner,
            notionalAmount,
            fixedRate,
            isPayingFixed,
            margin
        );

        if (matchedWithId != 0) {
            Swap storage matchedSwap = swaps[matchedWithId];
            matchedSwap.matched = true;
            matchedSwap.matchedWith = swapId;

            emit SwapsMatched(swapId, matchedWithId);
        }
    }

    function processRateAndSettlement(bytes memory data) internal {
        (uint256[] memory swapsToSettle, uint256 validatedRate) = abi.decode(
            data,
            (uint256[], uint256)
        );

        for (uint256 i = 0; i < swapsToSettle.length; i++) {
            settleSwap(swapsToSettle[i], validatedRate);
        }
    }

    function settleSwap(uint256 swapId, uint256 validatedRate) internal {
        Swap storage swap = swaps[swapId];
        require(swap.isActive && swap.matched, "Invalid swap");
        require(
            block.timestamp >= swap.lastSettlement + SETTLEMENT_PERIOD,
            "Too early"
        );

        Swap storage matchedSwap = swaps[swap.matchedWith];

        uint256 timePassed = block.timestamp - swap.lastSettlement;
        uint256 payment = calculatePayment(
            swap.notionalAmount,
            validatedRate,
            swap.fixedRate,
            timePassed
        );

        (
            address payer,
            address receiver,
            Swap storage payerSwap
        ) = validatedRate > swap.fixedRate
                ? (swap.owner, matchedSwap.owner, swap)
                : (matchedSwap.owner, swap.owner, matchedSwap);

        if (payerSwap.margin < payment) revert InsufficientMargin();
        payerSwap.margin -= payment;

        (bool success, ) = payable(receiver).call{value: payment}("");
        if (!success) revert PaymentFailed();

        if (block.timestamp >= swap.startTime + swap.duration) {
            swap.isActive = false;
            matchedSwap.isActive = false;

            if (swap.margin > 0) {
                (bool s1, ) = payable(swap.owner).call{value: swap.margin}("");
                if (!s1) revert PaymentFailed();
                swap.margin = 0;
            }
            if (matchedSwap.margin > 0) {
                (bool s2, ) = payable(matchedSwap.owner).call{
                    value: matchedSwap.margin
                }("");
                if (!s2) revert PaymentFailed();
                matchedSwap.margin = 0;
            }
        } else {
            swap.lastSettlement = block.timestamp;
            matchedSwap.lastSettlement = block.timestamp;
        }

        emit SwapSettled(swapId, validatedRate, payment, payer, receiver);
    }

    function calculatePayment(
        uint256 notional,
        uint256 variableRate,
        uint256 fixedRate,
        uint256 timeElapsed
    ) internal pure returns (uint256) {
        uint256 rateDiff = variableRate > fixedRate
            ? variableRate - fixedRate
            : fixedRate - variableRate;

        return
            (notional * rateDiff * timeElapsed) /
            (365 days * BASIS_POINTS_DIVISOR);
    }

    receive() external payable {}
}
