import { ethers } from "ethers";
import {
  variableLendingPoolAddress,
  variableLendingPoolABI,
  fixedLendingPoolAddress,
  fixedLendingPoolABI,
} from "./irsOperator";
import * as dotenv from "dotenv";
dotenv.config();

const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
const wallet1 = new ethers.Wallet(process.env.PRIVATE_KEY!, provider);
const wallet2 = new ethers.Wallet(process.env.PRIVATE_KEY_2!, provider);

const variableLendingPool = new ethers.Contract(
  variableLendingPoolAddress,
  variableLendingPoolABI,
  wallet1
);

const fixedLendingPool = new ethers.Contract(
  fixedLendingPoolAddress,
  fixedLendingPoolABI,
  wallet2
);

const setupLendingforUser1 = async () => {
  try {
    console.log(
      "\n--- Setting up lending positions for Wallet 1 (Variable Rate User) ---"
    );
    console.log("Using address:", wallet1.address);

    console.log("\nSetting up Variable Rate Position:");
    const varCollateral = ethers.parseEther("15"); // 15 ETH collateral
    const varBorrowAmount = ethers.parseEther("10"); // 10 ETH borrow

    console.log(
      `Depositing ${ethers.formatEther(varCollateral)} ETH as collateral...`
    );
    let tx = await variableLendingPool.deposit({ value: varCollateral });
    await tx.wait();
    console.log("Collateral deposited to Variable Pool");

    console.log(`Borrowing ${ethers.formatEther(varBorrowAmount)} ETH...`);
    tx = await variableLendingPool.borrow(varBorrowAmount);
    await tx.wait();
    console.log("Borrowed from Variable Pool");

    const varPosition = await variableLendingPool.getUserAccountData(
      wallet1.address
    );
    console.log("Variable Rate Position Created:", {
      collateral: ethers.formatEther(varPosition.totalCollateral),
      debt: ethers.formatEther(varPosition.totalDebt),
      healthFactor: varPosition.healthFactor.toString(),
    });

    console.log("\nWallet 1 lending position setup successfully!");
  } catch (error) {
    console.error("Failed to setup loans for Wallet 1:", error);
    throw error;
  }
};

const setupLendingForUser2 = async () => {
  try {
    console.log(
      "\n--- Setting up lending positions for Wallet 2 (Fixed Rate User) ---"
    );
    console.log("Using address:", wallet2.address);

    console.log("\nSetting up Fixed Rate Position:");
    const fixedCollateral = ethers.parseEther("15"); // 15 ETH collateral
    const fixedBorrowAmount = ethers.parseEther("10"); // 10 ETH borrow
    const duration = 365 * 24 * 60 * 60; // 1 year

    console.log(
      `Depositing ${ethers.formatEther(fixedCollateral)} ETH as collateral...`
    );
    let tx = await fixedLendingPool.depositCollateral({
      value: fixedCollateral,
    });
    await tx.wait();
    console.log("Collateral deposited to Fixed Pool");

    console.log(
      `Borrowing ${ethers.formatEther(fixedBorrowAmount)} ETH for 1 year...`
    );
    tx = await fixedLendingPool.openFixedPosition(fixedBorrowAmount, duration);
    await tx.wait();
    console.log("Borrowed from Fixed Pool");

    const fixedPosition = await fixedLendingPool.getUserFixedRatePosition(
      wallet2.address
    );
    console.log("Fixed Rate Position Created:", {
      principal: ethers.formatEther(fixedPosition[0]),
      fixedRate: fixedPosition[1].toString(),
      maturity: new Date(Number(fixedPosition[2]) * 1000).toLocaleString(),
      healthFactor: fixedPosition[3].toString(),
    });

    console.log("\nWallet 2 lending position setup successfully!");
  } catch (error) {
    console.error("Failed to setup loans for Wallet 2:", error);
    throw error;
  }
};

const main = async () => {
  console.log("\nInitial balances:");
  console.log(
    "Wallet 1:",
    ethers.formatEther(await provider.getBalance(wallet1.address)),
    "ETH"
  );
  console.log(
    "Wallet 2:",
    ethers.formatEther(await provider.getBalance(wallet2.address)),
    "ETH"
  );

  try {
    await setupLendingforUser1();
    await setupLendingForUser2();

    console.log("\nFinal balances:");
    console.log(
      "Wallet 1:",
      ethers.formatEther(await provider.getBalance(wallet1.address)),
      "ETH"
    );
    console.log(
      "Wallet 2:",
      ethers.formatEther(await provider.getBalance(wallet2.address)),
      "ETH"
    );

    console.log("\nAll lending positions setup successfully!");
  } catch (error) {
    console.error("Failed to setup lending positions:", error);
    throw error;
  }
};

main().catch(async (error: any) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
