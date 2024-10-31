// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {WadRayMath} from "./WadRayMath.sol";

contract MockFixedRateLendingPool is Pausable, Ownable {
    using WadRayMath for uint256;

    struct FixedRatePosition {
        uint256 principal; // Amount borrowed
        uint256 fixedRate; // Fixed interest rate (in ray - 1e27)
        uint256 startTime;
        uint256 maturity;
        uint256 collateral;
        bool isActive;
    }

    uint256 public constant MIN_DURATION = 30 days;
    uint256 public constant MAX_DURATION = 365 days;
    uint256 public constant LIQUIDATION_THRESHOLD = 150; // 150% collateralization
    uint256 public constant BASE_FIXED_RATE = 0.06e27; // 6% base fixed rate

    mapping(address => FixedRatePosition) public userPositions;
    uint256 public totalFixedBorrows;
    uint256 public currentFixedRate;

    event FixedPositionOpened(
        address indexed user,
        uint256 principal,
        uint256 fixedRate,
        uint256 maturity
    );
    event FixedPositionClosed(address indexed user, uint256 principal);
    event FixedRateUpdated(uint256 newRate);
    event CollateralWithdrawn(address indexed user, uint256 amount);
    event CollateralDeposited(address indexed user, uint256 amount);

    constructor(address initialOwner) Ownable() {
        currentFixedRate = BASE_FIXED_RATE;
    }

    function depositCollateral() external payable whenNotPaused {
        require(msg.value > 0, "Cannot deposit 0");

        FixedRatePosition storage position = userPositions[msg.sender];
        position.collateral += msg.value;

        emit CollateralDeposited(msg.sender, msg.value);
    }

    function openFixedPosition(
        uint256 borrowAmount,
        uint256 duration
    ) external whenNotPaused {
        require(borrowAmount > 0, "Cannot borrow 0");
        require(
            duration >= MIN_DURATION && duration <= MAX_DURATION,
            "Invalid duration"
        );

        require(
            address(this).balance >= borrowAmount,
            "Insufficient liquidity"
        );

        FixedRatePosition storage position = userPositions[msg.sender];

        uint256 requiredCollateral = (borrowAmount * LIQUIDATION_THRESHOLD) /
            100;
        require(
            position.collateral >= requiredCollateral,
            "Insufficient collateral"
        );

        position.principal = borrowAmount;
        position.fixedRate = currentFixedRate;
        position.startTime = block.timestamp;
        position.maturity = block.timestamp + duration;
        position.isActive = true;

        totalFixedBorrows += borrowAmount;

        (bool success, ) = payable(msg.sender).call{value: borrowAmount}("");
        require(success, "ETH transfer failed");

        emit FixedPositionOpened(
            msg.sender,
            borrowAmount,
            currentFixedRate,
            block.timestamp + duration
        );
    }

    function repayPosition() external payable whenNotPaused {
        FixedRatePosition storage position = userPositions[msg.sender];
        require(position.isActive, "No active position");

        uint256 interestOwed = calculateInterestOwed(msg.sender);
        uint256 totalOwed = position.principal + interestOwed;
        require(msg.value >= totalOwed, "Insufficient repayment");

        uint256 excess = msg.value - totalOwed;
        if (excess > 0) {
            (bool success, ) = payable(msg.sender).call{value: excess}("");
            require(success, "ETH excess return failed");
        }

        totalFixedBorrows -= position.principal;
        position.principal = 0;
        position.isActive = false;

        emit FixedPositionClosed(msg.sender, totalOwed);
    }

    function getUserFixedRatePosition(
        address user
    )
        external
        view
        returns (
            uint256 principal,
            uint256 fixedRate,
            uint256 maturity,
            uint256 healthFactor
        )
    {
        FixedRatePosition memory position = userPositions[user];
        require(position.isActive, "No active position");

        return (
            position.principal,
            position.fixedRate,
            position.maturity,
            (position.collateral * 100) / position.principal // health factor
        );
    }

    function getFixedRateData()
        external
        view
        returns (
            uint256 _currentFixedRate,
            uint256 _minDuration,
            uint256 _maxDuration
        )
    {
        return (currentFixedRate, MIN_DURATION, MAX_DURATION);
    }

    function withdrawCollateral(uint256 amount) external whenNotPaused {
        FixedRatePosition storage position = userPositions[msg.sender];
        require(amount <= position.collateral, "Insufficient collateral");

        if (position.isActive) {
            uint256 remainingCollateral = position.collateral - amount;
            uint256 requiredCollateral = (position.principal *
                LIQUIDATION_THRESHOLD) / 100;
            require(
                remainingCollateral >= requiredCollateral,
                "Would breach collateral requirement"
            );
        }

        position.collateral -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "ETH transfer failed");

        emit CollateralWithdrawn(msg.sender, amount);
    }

    function calculateInterestOwed(address user) public view returns (uint256) {
        FixedRatePosition memory position = userPositions[user];
        if (!position.isActive) return 0;

        uint256 timeElapsed = block.timestamp - position.startTime;
        return
            (position.principal.rayMul(position.fixedRate) * timeElapsed) /
            365 days;
    }

    function closePosition() external payable whenNotPaused {
        FixedRatePosition storage position = userPositions[msg.sender];
        require(position.isActive, "No active position");

        uint256 interestOwed = calculateInterestOwed(msg.sender);
        uint256 totalOwed = position.principal + interestOwed;

        require(msg.value >= totalOwed, "Insufficient repayment");

        // Return excess collateral
        uint256 excess = msg.value - totalOwed;
        if (excess > 0) {
            payable(msg.sender).transfer(excess);
        }

        totalFixedBorrows -= position.principal;
        position.isActive = false;

        emit FixedPositionClosed(msg.sender, position.principal);
    }

    // for testing
    function setFixedRate(uint256 newRate) external onlyOwner {
        currentFixedRate = newRate;
        emit FixedRateUpdated(newRate);
    }

    function getAvailableLiquidity() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}
