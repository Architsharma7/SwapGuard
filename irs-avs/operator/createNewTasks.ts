import { ethers } from "ethers";
import { TaskType } from "./irsOperator";
import * as dotenv from "dotenv";
const fs = require("fs");
const path = require("path");
dotenv.config();

const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
const wallet1 = new ethers.Wallet(process.env.PRIVATE_KEY!, provider);
const wallet2 = new ethers.Wallet(process.env.PRIVATE_KEY_2!, provider);
const chainId = 31337;

const avsDeploymentData = JSON.parse(
  fs.readFileSync(
    path.resolve(__dirname, `../contracts/deployments/irs-avs/${chainId}.json`),
    "utf8"
  )
);

const irsServiceManagerAddress = avsDeploymentData.addresses.irsServiceManager;

const irsServiceManagerABI = JSON.parse(
  fs.readFileSync(
    path.resolve(__dirname, "../abis/IRSServiceManager.json"),
    "utf8"
  )
);

const irsManager = new ethers.Contract(
  irsServiceManagerAddress,
  irsServiceManagerABI,
  wallet2
);

// const irsManager2 = new ethers.Contract(
//   irsServiceManagerAddress,
//   irsServiceManagerABI,
//   wallet2
// );

const createSwap = async () => {
  try {
    console.log("\n--- Creating Opposite Swap Requests ---");

    const notionalAmount = ethers.parseEther("10");
    const fixedRate = 600; // 6.00%
    const duration = 365 * 24 * 60 * 60; // 1 year
    const margin = ethers.parseEther("1");

    // console.log("\nCreating Variable->Fixed Swap Request");
    // console.log("From address:", wallet1.address);

    // console.log("\nWallet1 Swap Parameters:", {
    //   notionalAmount: ethers.formatEther(notionalAmount),
    //   fixedRate: fixedRate / 100 + "%",
    //   duration: duration / (24 * 60 * 60) + " days",
    //   isPayingFixed: true,
    //   margin: ethers.formatEther(margin),
    // });

    // const swapData1 = ethers.AbiCoder.defaultAbiCoder().encode(
    //   ["address", "uint256", "uint256", "bool", "uint256", "uint256"],
    //   [
    //     wallet1.address,
    //     notionalAmount,
    //     fixedRate,
    //     true, // wants to pay fixed
    //     duration,
    //     margin,
    //   ]
    // );

    // let tx = await irsManager.createNewTask(
    //   TaskType.SWAP_VALIDATION,
    //   swapData1,
    //   { value: margin }
    // );
    // await tx.wait();
    // console.log("Wallet1 swap request submitted");

    // Wait before creating opposite swap
    // console.log("\nWaiting before creating opposite swap...");
    // await new Promise((resolve) => setTimeout(resolve, 4000));

    // Fixed Rate User (Wallet2) creates opposite swap
    console.log("\nCreating Fixed->Variable Swap Request");
    console.log("From address:", wallet2.address);

    console.log("\nWallet2 Swap Parameters:", {
      notionalAmount: ethers.formatEther(notionalAmount),
      fixedRate: fixedRate / 100 + "%",
      duration: duration / (24 * 60 * 60) + " days",
      isPayingFixed: false,
      margin: ethers.formatEther(margin),
    });

    const swapData2 = ethers.AbiCoder.defaultAbiCoder().encode(
      ["address", "uint256", "uint256", "bool", "uint256", "uint256"],
      [
        wallet2.address,
        notionalAmount,
        fixedRate,
        false, // wants to pay variable
        duration,
        margin,
      ]
    );

    let tx = await irsManager.createNewTask(
      TaskType.SWAP_VALIDATION,
      swapData2,
      {
        value: margin,
      }
    );
    await tx.wait();
    console.log("Wallet2 swap request submitted");

    // console.log("\nBoth swap requests created successfully!");
    // console.log("\nWaiting for operator to validate and match swaps...");
    // console.log(
    //   "(You can check contract events for SwapCreated and SwapsMatched events)"
    // );
  } catch (error) {
    console.error("Failed to create swaps:", error);
    throw error;
  }
};

createSwap().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
