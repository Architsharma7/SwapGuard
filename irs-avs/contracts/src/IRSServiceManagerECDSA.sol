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
        MATCH_VALIDATION,
        SETTLEMENT
    }

    struct Task {
        uint32 taskCreatedBlock;
        TaskType taskType;
        bytes payload;
    }

    struct Swap {
        address owner;
        uint256 notionalAmount;
        uint256 fixedRate;
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
    uint256 public constant SETTLEMENT_PERIOD = 3 minutes; //only for testing purposes
    uint256 public constant SETTLEMENT_REWARD_PERCENTAGE = 10; // 0.1%

    uint32 public latestTaskNum;
    mapping(uint32 => bytes32) public allTaskHashes;
    mapping(address => mapping(uint32 => bytes)) public allTaskResponses;
    mapping(uint256 => Swap) public swaps;
    uint256 public nextSwapId;

    event NewTaskCreated(uint32 indexed taskIndex, Task task);
    event TaskResponded(uint32 indexed taskIndex, Task task, address operator);
    event SwapsMatched(
        uint256 indexed swap1Id,
        uint256 indexed swap2Id,
        address indexed matcher
    );
    event SwapSettled(
        uint256 indexed swapId,
        uint256 variableRate,
        uint256 payment,
        address indexed payer,
        address indexed receiver,
        address settler,
        uint256 reward
    );

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

        require(
            operatorHasMinimumWeight(msg.sender),
            "Operator does not meet minimum weight requirement"
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
            require(user == msg.sender, "Only owner can create swap");
            uint256 requiredMargin = (notionalAmount *
                INITIAL_MARGIN_PERCENTAGE) / BASIS_POINTS_DIVISOR;
            require(msg.value >= requiredMargin, "Insufficient margin");
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
    ) external {
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
        address signer = ethSignedMessageHash.recover(signature);
        require(
            ECDSAStakeRegistry(stakeRegistry).operatorRegistered(signer),
            "Invalid operator"
        );

        allTaskResponses[msg.sender][referenceTaskIndex] = signature;

        if (task.taskType == TaskType.SWAP_VALIDATION) {
            processValidatedSwap(task.payload);
        } else if (task.taskType == TaskType.MATCH_VALIDATION) {
            processValidatedMatch(task.payload);
        } else if (task.taskType == TaskType.SETTLEMENT) {
            processValidatedSettlement(task.payload);
        }

        emit TaskResponded(referenceTaskIndex, task, msg.sender);
    }

    function processValidatedSwap(bytes memory payload) internal {
        (
            address owner,
            uint256 notionalAmount,
            uint256 fixedRate,
            bool isPayingFixed,
            uint256 duration,
            uint256 margin
        ) = abi.decode(
                payload,
                (address, uint256, uint256, bool, uint256, uint256)
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
            matched: false,
            matchedWith: 0
        });

        emit SwapCreated(
            swapId,
            owner,
            notionalAmount,
            fixedRate,
            isPayingFixed,
            margin
        );
    }

    function processValidatedMatch(bytes memory payload) internal {
        (uint256 swap1Id, uint256 swap2Id, bool isValid, address matcher) = abi
            .decode(payload, (uint256, uint256, bool, address));

        require(isValid, "Match validation failed");

        Swap storage swap1 = swaps[swap1Id];
        Swap storage swap2 = swaps[swap2Id];

        swap1.matched = true;
        swap1.matchedWith = swap2Id;
        swap2.matched = true;
        swap2.matchedWith = swap1Id;

        emit SwapsMatched(swap1Id, swap2Id, matcher);
    }

    function processValidatedSettlement(bytes memory payload) internal {
        (
            uint256[] memory swapIds,
            uint256 variableRate,
            bool[] memory validationResults,
            address settler
        ) = abi.decode(payload, (uint256[], uint256, bool[], address));

        for (uint256 i = 0; i < swapIds.length; i++) {
            if (validationResults[i]) {
                _settleValidatedSwap(swapIds[i], variableRate, settler);
            }
        }
    }

    function _settleValidatedSwap(
        uint256 swapId,
        uint256 variableRate,
        address settler
    ) internal {
        Swap storage swap = swaps[swapId];
        require(swap.isActive && swap.matched, "Invalid swap");

        Swap storage matchedSwap = swaps[swap.matchedWith];
        uint256 timePassed = block.timestamp - swap.lastSettlement;

        uint256 payment = calculatePayment(
            swap.notionalAmount,
            variableRate,
            swap.fixedRate,
            timePassed
        );

        uint256 settlementReward = (payment * SETTLEMENT_REWARD_PERCENTAGE) /
            BASIS_POINTS_DIVISOR;

        (
            address payer,
            address receiver,
            Swap storage payerSwap
        ) = variableRate > swap.fixedRate
                ? (swap.owner, matchedSwap.owner, swap)
                : (matchedSwap.owner, swap.owner, matchedSwap);

        require(
            payerSwap.margin >= payment + settlementReward,
            "Insufficient margin"
        );
        payerSwap.margin -= (payment + settlementReward);

        _safeTransferETH(receiver, payment);
        _safeTransferETH(settler, settlementReward);

        if (block.timestamp >= swap.startTime + swap.duration) {
            _closeSwaps(swap, matchedSwap);
        } else {
            swap.lastSettlement = block.timestamp;
            matchedSwap.lastSettlement = block.timestamp;
        }

        emit SwapSettled(
            swapId,
            variableRate,
            payment,
            payer,
            receiver,
            settler,
            settlementReward
        );
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

    function _closeSwaps(Swap storage swap1, Swap storage swap2) internal {
        swap1.isActive = false;
        swap2.isActive = false;

        if (swap1.margin > 0) {
            uint256 margin = swap1.margin;
            swap1.margin = 0;
            _safeTransferETH(swap1.owner, margin);
        }

        if (swap2.margin > 0) {
            uint256 margin = swap2.margin;
            swap2.margin = 0;
            _safeTransferETH(swap2.owner, margin);
        }
    }

    function _safeTransferETH(address to, uint256 amount) internal {
        (bool success, ) = to.call{value: amount}("");
        require(success, "ETH transfer failed");
    }

    function operatorHasMinimumWeight(
        address operator
    ) public view returns (bool) {
        return
            ECDSAStakeRegistry(stakeRegistry).getOperatorWeight(operator) >=
            ECDSAStakeRegistry(stakeRegistry).minimumWeight();
    }

    function getSwap(
        uint256 swapId
    )
        external
        view
        returns (
            address owner,
            uint256 notionalAmount,
            uint256 fixedRate,
            bool isPayingFixed,
            uint256 margin,
            uint256 startTime,
            uint256 duration,
            uint256 lastSettlement,
            bool isActive,
            bool matched,
            uint256 matchedWith
        )
    {
        Swap storage swap = swaps[swapId];
        return (
            swap.owner,
            swap.notionalAmount,
            swap.fixedRate,
            swap.isPayingFixed,
            swap.margin,
            swap.startTime,
            swap.duration,
            swap.lastSettlement,
            swap.isActive,
            swap.matched,
            swap.matchedWith
        );
    }

    receive() external payable {}
}
