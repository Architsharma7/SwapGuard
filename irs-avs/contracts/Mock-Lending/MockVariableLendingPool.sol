// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {WadRayMath} from "./WadRayMath.sol";

contract MockVariableLendingPool is Pausable, Ownable {
    using WadRayMath for uint256;

    uint256 public constant OPTIMAL_UTILIZATION_RATE = 0.8e27; // 80%
    uint256 public constant LTV_RATIO = 80; // 80% LTV
    uint256 public constant BASE_VARIABLE_BORROW_RATE = 0.01e27; // 1%
    uint256 public constant LIQUIDATION_THRESHOLD = 150; // 150% collateralization

    struct UserAccount {
        uint256 collateral;
        uint256 debt;
        uint256 lastUpdateTimestamp;
        bool isActive;
    }

    struct ReserveData {
        uint256 currentLiquidityRate; // APY for lenders
        uint256 currentVariableBorrowRate; // APY for borrowers
        uint256 currentStableBorrowRate; // Not used but kept for Aave compatibility
        uint256 lastUpdateTimestamp;
        uint256 totalDeposits;
        uint256 totalBorrows;
    }

    mapping(address => UserAccount) public userAccounts;
    ReserveData public reserveData;

    event Deposit(address indexed user, uint256 amount);
    event Borrow(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event ReserveDataUpdated(uint256 liquidityRate, uint256 variableBorrowRate);

    constructor(address initialOwner) Ownable() {
        reserveData.currentVariableBorrowRate = 0.05e27; // 5% APY
        reserveData.lastUpdateTimestamp = block.timestamp;
    }

    function deposit() external payable whenNotPaused {
        require(msg.value > 0, "Cannot deposit 0");

        UserAccount storage account = userAccounts[msg.sender];
        account.collateral += msg.value;
        account.isActive = true;
        account.lastUpdateTimestamp = block.timestamp;

        reserveData.totalDeposits += msg.value;
        _updateReserveData();

        emit Deposit(msg.sender, msg.value);
    }

    function borrow(uint256 amount) external whenNotPaused {
        require(amount > 0, "Cannot borrow 0");
        UserAccount storage account = userAccounts[msg.sender];
        require(account.collateral > 0, "No collateral");

        uint256 maxBorrow = (account.collateral * 100) / LIQUIDATION_THRESHOLD;
        require(account.debt + amount <= maxBorrow, "Insufficient collateral");

        account.debt += amount;
        account.lastUpdateTimestamp = block.timestamp;
        reserveData.totalBorrows += amount;

        _updateReserveData();

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "ETH transfer failed");

        emit Borrow(msg.sender, amount);
    }

    function repay() external payable whenNotPaused {
        require(msg.value > 0, "Cannot repay 0");
        UserAccount storage account = userAccounts[msg.sender];
        require(account.debt > 0, "No debt to repay");

        uint256 interest = calculateInterest(account);
        uint256 totalOwed = account.debt + interest;
        require(msg.value >= totalOwed, "Insufficient repayment");

        account.debt = 0;
        reserveData.totalBorrows -= account.debt;

        uint256 excess = msg.value - totalOwed;
        if (excess > 0) {
            (bool success, ) = payable(msg.sender).call{value: excess}("");
            require(success, "ETH excess return failed");
        }

        emit Repay(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external whenNotPaused {
        UserAccount storage account = userAccounts[msg.sender];
        require(amount <= account.collateral, "Insufficient collateral");
        uint256 remainingCollateral = account.collateral - amount;
        if (account.debt > 0) {
            require(
                (remainingCollateral * LTV_RATIO) / 100 >= account.debt,
                "Would exceed LTV ratio"
            );
        }

        account.collateral -= amount;
        reserveData.totalDeposits -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "ETH transfer failed");

        emit Withdraw(msg.sender, amount);
    }

    function calculateInterest(
        UserAccount memory account
    ) internal view returns (uint256) {
        if (account.debt == 0) return 0;

        uint256 timeElapsed = block.timestamp - account.lastUpdateTimestamp;
        return
            (account.debt.rayMul(reserveData.currentVariableBorrowRate) *
                timeElapsed) / 365 days;
    }

    function getAvailableLiquidity() external view returns (uint256) {
        return address(this).balance;
    }

    function getUserAccountData(
        address user
    )
        external
        view
        returns (
            uint256 totalCollateral,
            uint256 totalDebt,
            uint256 availableBorrows,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        )
    {
        UserAccount memory account = userAccounts[user];

        totalCollateral = account.collateral;
        totalDebt = account.debt;

        availableBorrows =
            ((account.collateral * LTV_RATIO) / 100) -
            account.debt;

        currentLiquidationThreshold = LIQUIDATION_THRESHOLD;
        ltv = LTV_RATIO;

        healthFactor = account.debt == 0
            ? type(uint256).max
            : (account.collateral * LIQUIDATION_THRESHOLD) /
                (account.debt * 100);
    }

    function getReserveData()
        external
        view
        returns (
            uint256 currentLiquidityRate,
            uint256 currentVariableBorrowRate,
            uint256 currentStableBorrowRate
        )
    {
        return (
            reserveData.currentLiquidityRate,
            reserveData.currentVariableBorrowRate,
            reserveData.currentStableBorrowRate
        );
    }

    function _updateReserveData() internal {
        if (reserveData.totalDeposits == 0) return;

        uint256 utilizationRate = (reserveData.totalBorrows * 1e27) /
            reserveData.totalDeposits;

        // Simple interest rate model
        if (utilizationRate <= OPTIMAL_UTILIZATION_RATE) {
            reserveData.currentVariableBorrowRate =
                BASE_VARIABLE_BORROW_RATE +
                (utilizationRate * 0.1e27) /
                OPTIMAL_UTILIZATION_RATE; // Linear increase
        } else {
            reserveData.currentVariableBorrowRate =
                BASE_VARIABLE_BORROW_RATE +
                0.1e27 + // Optimal rate
                ((utilizationRate - OPTIMAL_UTILIZATION_RATE) * 0.4e27) /
                (1e27 - OPTIMAL_UTILIZATION_RATE); // Steeper increase
        }

        reserveData.lastUpdateTimestamp = block.timestamp;

        emit ReserveDataUpdated(
            reserveData.currentLiquidityRate,
            reserveData.currentVariableBorrowRate
        );
    }

    // (for testing)
    function setVariableBorrowRate(uint256 newRate) external onlyOwner {
        reserveData.currentVariableBorrowRate = newRate;
        emit ReserveDataUpdated(
            reserveData.currentLiquidityRate,
            reserveData.currentVariableBorrowRate
        );
    }

    receive() external payable {}
}
