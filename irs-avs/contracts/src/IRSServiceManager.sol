// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {ServiceManagerBase} from "@eigenlayer-middleware/src/ServiceManagerBase.sol";
import {TaskManager} from "./TaskManager.sol";
import {Pausable} from "@eigenlayer/contracts/permissions/Pausable.sol";
import {OperatorAllowlist} from "./OperatorAllowlist.sol";
import {IAVSDirectory} from "@eigenlayer/contracts/interfaces/IAVSDirectory.sol";
import {IRewardsCoordinator} from "@eigenlayer/contracts/interfaces/IRewardsCoordinator.sol";
import {IPauserRegistry} from "@eigenlayer/contracts/interfaces/IPauserRegistry.sol";
import {IStakeRegistry} from "@eigenlayer-middleware/src/interfaces/IStakeRegistry.sol";
import {IRegistryCoordinator} from "@eigenlayer-middleware/src/interfaces/IRegistryCoordinator.sol";

contract IRSServiceManager is
    ServiceManagerBase,
    TaskManager,
    Pausable,
    OperatorAllowlist
{
    enum TaskType {
        SWAP_VALIDATION,
        RATE_AND_SETTLEMENT
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

    // ERRORS
    error InsufficientMargin();
    error InvalidTask();
    error PaymentFailed();

    // CONSTANTS
    uint256 public constant INITIAL_MARGIN_PERCENTAGE = 10_00; // 10%
    uint256 public constant BASIS_POINTS_DIVISOR = 10000;
    uint256 public constant SETTLEMENT_PERIOD = 30 days;

    // STATE
    mapping(uint256 => Swap) public swaps;
    uint256 public nextSwapId;

    // EVENTS
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
        IAVSDirectory __avsDirectory,
        IRewardsCoordinator __rewardsCoordinator,
        IRegistryCoordinator __registryCoordinator,
        IStakeRegistry __stakeRegistry,
        uint32 _taskResponseWindowBlock
    )
        ServiceManagerBase(
            __avsDirectory,
            __rewardsCoordinator,
            __registryCoordinator,
            __stakeRegistry
        )
        TaskManager(__registryCoordinator, _taskResponseWindowBlock)
    {
        _disableInitializers();
    }

    function initialize(
        IPauserRegistry pauserRegistry_,
        uint256 initialPausedStatus_,
        address initialOwner_,
        address rewardsInitiator_,
        address allowlistManager_,
        address aggregator_,
        address generator_
    ) external initializer {
        _initializePauser(pauserRegistry_, initialPausedStatus_);
        __ServiceManagerBase_init(initialOwner_, rewardsInitiator_);
        __OperatorAllowlist_init(allowlistManager_, true);
        __TaskManager_init(aggregator_, generator_, initialOwner_);
    }

    function createTask(
        bytes calldata message,
        uint32 quorumThresholdPercentage,
        bytes calldata quorumNumbers
    ) external payable whenNotPaused {
        // Verify margin for swap validation tasks
        (TaskType taskType, ) = abi.decode(message, (TaskType, bytes));
        if (taskType == TaskType.SWAP_VALIDATION) {
            (, address user, uint256 notionalAmount, , , , ) = abi.decode(
                message,
                (TaskType, address, uint256, uint256, bool, uint256, uint256)
            );

            uint256 requiredMargin = (notionalAmount *
                INITIAL_MARGIN_PERCENTAGE) / BASIS_POINTS_DIVISOR;
            if (msg.value < requiredMargin) revert InsufficientMargin();
        }

        // Store task hash
        allTaskHashes[latestTaskNum] = keccak256(
            abi.encode(
                Task({
                    taskCreatedBlock: uint32(block.number),
                    quorumThresholdPercentage: quorumThresholdPercentage,
                    message: message,
                    quorumNumbers: quorumNumbers
                })
            )
        );

        _createNewTask(message, quorumThresholdPercentage, quorumNumbers);
    }

    function respondToTask(
        Task calldata task,
        TaskResponse calldata taskResponse,
        NonSignerStakesAndSignature memory nonSignerStakesAndSignature
    ) external onlyAggregator whenNotPaused {
        // Verify task matches
        if (
            keccak256(abi.encode(task)) !=
            allTaskHashes[taskResponse.referenceTaskIndex]
        ) revert InvalidTask();

        // Verify signatures and quorum
        (
            QuorumStakeTotals memory quorumStakeTotals,
            bytes32 hashOfNonSigners
        ) = checkSignatures(
                keccak256(abi.encode(taskResponse)),
                task.quorumNumbers,
                task.taskCreatedBlock,
                nonSignerStakesAndSignature
            );

        // Verify quorum threshold
        for (uint256 i = 0; i < task.quorumNumbers.length; i++) {
            if (
                quorumStakeTotals.signedStakeForQuorum[i] * 100 <
                quorumStakeTotals.totalStakeForQuorum[i] *
                    task.quorumThresholdPercentage
            ) revert("Insufficient quorum");
        }

        // Process task based on type
        (TaskType taskType, bytes memory data) = abi.decode(
            task.message,
            (TaskType, bytes)
        );

        if (taskType == TaskType.SWAP_VALIDATION) {
            processSwapValidation(data);
        } else {
            processRateAndSettlement(data);
        }

        // Store task response
        allTaskResponses[taskResponse.referenceTaskIndex] = keccak256(
            abi.encode(
                taskResponse,
                TaskResponseMetadata(uint32(block.timestamp), hashOfNonSigners)
            )
        );

        emit TaskResponded(
            taskResponse,
            TaskResponseMetadata(uint32(block.timestamp), hashOfNonSigners)
        );
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

        // Determine payer and receiver
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

        // Check if duration expired
        if (block.timestamp >= swap.startTime + swap.duration) {
            swap.isActive = false;
            matchedSwap.isActive = false;

            // Return remaining margins
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
