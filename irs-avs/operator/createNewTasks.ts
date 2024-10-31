import { ethers } from "ethers";
import { TaskType } from "./irsOperator";
import * as dotenv from "dotenv";
const fs = require("fs");
import readline from "readline";
const path = require("path");
dotenv.config();

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
});

const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
const wallet1 = new ethers.Wallet(process.env.PRIVATE_KEY!, provider);
const wallet2 = new ethers.Wallet(process.env.PRIVATE_KEY_2!, provider);
const chainId = 31337;

const questionAsync = (query: string): Promise<string> => {
  return new Promise((resolve) => rl.question(query, resolve));
};

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

const irsManager1 = new ethers.Contract(
  irsServiceManagerAddress,
  irsServiceManagerABI,
  wallet1
);

const irsManager2 = new ethers.Contract(
  irsServiceManagerAddress,
  irsServiceManagerABI,
  wallet2
);

const createSwap = async () => {
  try {
    console.log("\n--- Creating Opposite Swap Requests ---");

    const notionalAmount = ethers.parseEther("10");
    const fixedRate = 600; // 6.00%
    const duration = 365 * 24 * 60 * 60; // 1 year
    const margin = ethers.parseEther("1");

    console.log("\nCreating Variable->Fixed Swap Request");
    console.log("From address:", wallet1.address);

    console.log("\nWallet1 Swap Parameters:", {
      notionalAmount: ethers.formatEther(notionalAmount),
      fixedRate: fixedRate / 100 + "%",
      duration: duration / (24 * 60 * 60) + " days",
      isPayingFixed: true,
      margin: ethers.formatEther(margin),
    });

    const swapData1 = ethers.AbiCoder.defaultAbiCoder().encode(
      ["address", "uint256", "uint256", "bool", "uint256", "uint256"],
      [
        wallet1.address,
        notionalAmount,
        fixedRate,
        true, // wants to pay fixed
        duration,
        margin,
      ]
    );

    let tx1 = await irsManager1.createNewTask(
      TaskType.SWAP_VALIDATION,
      swapData1,
      { value: margin }
    );
    await tx1.wait();
    console.log("Wallet1 swap request submitted");

    console.log("\nWaiting before creating opposite swap...");
    await new Promise((resolve) => setTimeout(resolve, 4000));

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

    let tx = await irsManager2.createNewTask(
      TaskType.SWAP_VALIDATION,
      swapData2,
      {
        value: margin,
      }
    );
    await tx.wait();
    console.log("Wallet2 swap request submitted");

    console.log("\nBoth swap requests created successfully!");
  } catch (error) {
    console.error("Failed to create swaps:", error);
    throw error;
  }
};

const createMatchValidationTask = async () => {
  const { unmatchedSwaps } = await displayAllSwaps();

  if (unmatchedSwaps.length < 2) {
    console.log("Not enough unmatched swaps to create a match");
    rl.close();
    return;
  }

  const swap1Id = await questionAsync("\nEnter first Swap ID: ");
  const swap2Id = await questionAsync("Enter second Swap ID: ");

  try {
    const tx = await irsManager1.createNewTask(
      TaskType.MATCH_VALIDATION,
      ethers.AbiCoder.defaultAbiCoder().encode(
        ["uint256", "uint256", "address"],
        [swap1Id, swap2Id, wallet1.address]
      )
    );
    await tx.wait();
    console.log("Match validation task created. Transaction hash:", tx.hash);
  } catch (error) {
    console.error("Error creating match validation task:", error);
  } finally {
    rl.close();
  }
};

interface SwapInfo {
  id: number;
  owner: string;
  notional: string;
  fixedRate: string;
  isPayingFixed: boolean;
  duration: string;
  matched: boolean;
  matchedWith: number;
  lastSettlement: Date;
  startTime: Date;
}

const displayAllSwaps = async () => {
  console.log("\n=== Current Swaps ===");
  const nextSwapId = await irsManager1.nextSwapId();

  const unmatchedSwaps: SwapInfo[] = [];
  const matchedSwaps: SwapInfo[] = [];

  // First pass: Collect all swaps
  for (let i = 0; i < nextSwapId; i++) {
    const swap = await irsManager1.swaps(i);
    if (swap.isActive) {
      const swapInfo: SwapInfo = {
        id: i,
        owner: swap.owner.slice(0, 6) + "..." + swap.owner.slice(-4),
        notional: ethers.formatEther(swap.notionalAmount),
        fixedRate: (Number(swap.fixedRate) / 100).toString() + "%",
        isPayingFixed: swap.isPayingFixed,
        duration: Math.floor(Number(swap.duration) / (24 * 60 * 60)) + " days",
        matched: swap.matched,
        matchedWith: Number(swap.matchedWith),
        lastSettlement: new Date(Number(swap.lastSettlement) * 1000),
        startTime: new Date(Number(swap.startTime) * 1000),
      };

      if (!swap.matched) {
        unmatchedSwaps.push(swapInfo);
      } else {
        matchedSwaps.push(swapInfo);
      }
    }
  }

  console.log("\nUnmatched Swaps:");
  console.log("ID | Owner | Notional | Fixed Rate | Direction | Duration");
  console.log("-".repeat(70));

  if (unmatchedSwaps.length === 0) {
    console.log("No unmatched swaps found");
  } else {
    unmatchedSwaps.forEach((swap) => {
      console.log(
        `${swap.id} | ${swap.owner} | ${swap.notional} ETH | ${
          swap.fixedRate
        } | ${swap.isPayingFixed ? "Pay Fixed" : "Pay Variable"} | ${
          swap.duration
        }`
      );
    });
  }

  console.log("\nMatched Pairs:");
  console.log(
    "Pair IDs | Notional | Fixed Rate | Last Settlement | Next Settlement"
  );
  console.log("-".repeat(80));

  const displayedPairs = new Set<string>();

  matchedSwaps.forEach((swap) => {
    const matchedSwap = matchedSwaps.find((s) => s.id === swap.matchedWith);
    if (matchedSwap && !displayedPairs.has(`${swap.id}-${matchedSwap.id}`)) {
      const pairKey = `${Math.min(swap.id, matchedSwap.id)}-${Math.max(
        swap.id,
        matchedSwap.id
      )}`;
      displayedPairs.add(pairKey);

      const nextSettlement = new Date(
        swap.lastSettlement.getTime() + 30 * 60 * 100
      );
      console.log(
        `${pairKey} | ${swap.notional} ETH | ${
          swap.fixedRate
        } | ${swap.lastSettlement.toLocaleString()} | ${nextSettlement.toLocaleString()}`
      );
    }
  });

  return { unmatchedSwaps, matchedSwaps };
};

const createSettlementTask = async () => {
  console.log("\n=== Creating Settlement Task ===");

  const { matchedSwaps } = await displayAllSwaps();

  // Filter settleable swaps
  const SETTLEMENT_PERIOD = 30 * 60; // 3 minutes
  const currentTime = Math.floor(Date.now() / 1000);

  const settleableSwaps = matchedSwaps.filter(
    (swap) =>
      swap.matched &&
      currentTime >= Number(swap.lastSettlement) + SETTLEMENT_PERIOD
  );

  console.log("\nSwaps eligible for settlement:");
  console.log("ID | Last Settlement | Time Until Settleable");
  console.log("-".repeat(60));

  for (const swap of matchedSwaps) {
    const timeUntilSettlement =
      Number(swap.lastSettlement) + SETTLEMENT_PERIOD - currentTime;
    const status =
      timeUntilSettlement <= 0
        ? "Ready"
        : `${Math.ceil(timeUntilSettlement / (24 * 60 * 60))} days remaining`;

    console.log(
      `${swap.id} | ${swap.lastSettlement.toLocaleString()} | ${status}`
    );
  }

  if (settleableSwaps.length === 0) {
    console.log("\nNo swaps are currently eligible for settlement");
    rl.close();
    return;
  }

  console.log(
    "\nSettleable swap IDs:",
    settleableSwaps.map((s) => s.id).join(", ")
  );

  const selectedIds = await questionAsync(
    "\nEnter Swap IDs to settle (comma-separated) or 'all' for all eligible swaps: "
  );

  let swapsToSettle: number[];
  if (selectedIds.toLowerCase() === "all") {
    swapsToSettle = settleableSwaps.map((s) => s.id);
  } else {
    swapsToSettle = selectedIds.split(",").map((id) => parseInt(id.trim()));
    // Validate selected IDs
    const areValidIds = swapsToSettle.every((id) =>
      settleableSwaps.some((swap) => swap.id === id)
    );

    if (!areValidIds) {
      console.log("Some selected swaps are not eligible for settlement");
      rl.close();
      return;
    }
  }

  try {
    const tx = await irsManager1.createNewTask(
      TaskType.SETTLEMENT,
      ethers.AbiCoder.defaultAbiCoder().encode(
        ["uint256[]", "address"],
        [swapsToSettle, wallet1.address]
      )
    );
    await tx.wait();
    console.log("Settlement task created. Transaction hash:", tx.hash);
  } catch (error) {
    console.error("Error creating settlement task:", error);
  } finally {
    rl.close();
  }
};

const main = () => {
  const taskType = process.argv[2];

  switch (taskType) {
    case "swap":
      createSwap();
      break;
    case "match":
      createMatchValidationTask();
      break;
    case "settle":
      createSettlementTask();
    case "list":
      displayAllSwaps();
      break;
    default:
      console.error("Invalid task type. Use 'swap', 'match', or 'settle'.");
      process.exit(1);
  }
};

main();
