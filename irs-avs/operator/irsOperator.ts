import { ethers } from "ethers";
import * as dotenv from "dotenv";
const fs = require("fs");
const path = require("path");
dotenv.config();

if (!Object.keys(process.env).length) {
  throw new Error("process.env object is empty");
}

export enum TaskType {
  SWAP_VALIDATION,
  RATE_AND_SETTLEMENT,
}

const SETTLEMENT_CHECK_INTERVAL = 24000; // ms
const MIN_HEALTH_FACTOR = 150; // 150%
const MAX_RATE_DEVIATION = 200; // 2%

const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY!, provider);
let chainId = 31337;

export const avsDeploymentData = JSON.parse(
  fs.readFileSync(
    path.resolve(__dirname, `../contracts/deployments/irs-avs/${chainId}.json`),
    "utf8"
  )
);
const coreDeploymentData = JSON.parse(
  fs.readFileSync(
    path.resolve(__dirname, `../contracts/deployments/core/${chainId}.json`),
    "utf8"
  )
);

const delegationManagerAddress = coreDeploymentData.addresses.delegation;
const avsDirectoryAddress = coreDeploymentData.addresses.avsDirectory;
const irsServiceManagerAddress = avsDeploymentData.addresses.irsServiceManager;
const ecdsaStakeRegistryAddress = avsDeploymentData.addresses.stakeRegistry;
export const variableLendingPoolAddress =
  avsDeploymentData.addresses.mockVariableLendingPool;
export const fixedLendingPoolAddress =
  avsDeploymentData.addresses.mockFixedLendingPool;

const delegationManagerABI = JSON.parse(
  fs.readFileSync(
    path.resolve(__dirname, "../abis/IDelegationManager.json"),
    "utf8"
  )
);

const ecdsaRegistryABI = JSON.parse(
  fs.readFileSync(
    path.resolve(__dirname, "../abis/ECDSAStakeRegistry.json"),
    "utf8"
  )
);

const irsServiceManagerABI = JSON.parse(
  fs.readFileSync(
    path.resolve(__dirname, "../abis/IRSServiceManager.json"),
    "utf8"
  )
);

const avsDirectoryABI = JSON.parse(
  fs.readFileSync(path.resolve(__dirname, "../abis/IAVSDirectory.json"), "utf8")
);

export const variableLendingPoolABI = JSON.parse(
  fs.readFileSync(
    path.resolve(__dirname, "../abis/MockVariableLendingPool.json"),
    "utf8"
  )
);
export const fixedLendingPoolABI = JSON.parse(
  fs.readFileSync(
    path.resolve(__dirname, "../abis/MockFixedRateLendingPool.json"),
    "utf8"
  )
);

const delegationManager = new ethers.Contract(
  delegationManagerAddress,
  delegationManagerABI,
  wallet
);
export const irsManager = new ethers.Contract(
  irsServiceManagerAddress,
  irsServiceManagerABI,
  wallet
);
const ecdsaRegistryContract = new ethers.Contract(
  ecdsaStakeRegistryAddress,
  ecdsaRegistryABI,
  wallet
);
const avsDirectory = new ethers.Contract(
  avsDirectoryAddress,
  avsDirectoryABI,
  wallet
);
export const variableLendingPool = new ethers.Contract(
  variableLendingPoolAddress,
  variableLendingPoolABI,
  provider
);
export const fixedLendingPool = new ethers.Contract(
  fixedLendingPoolAddress,
  fixedLendingPoolABI,
  provider
);

const registerOperator = async () => {
  try {
    // TODO: Check if operator is already registered
    try {
      const isAlreadyRegistered = await delegationManager.isOperator(
        wallet.address
      );
      if (isAlreadyRegistered) {
        console.log("Operator already registered");
        return;
      }
    } catch (error) {
      console.log(error);
    }
    const tx1 = await delegationManager.registerAsOperator(
      {
        __deprecated_earningsReceiver: wallet.address,
        delegationApprover: "0x0000000000000000000000000000000000000000",
        stakerOptOutWindowBlocks: 0,
      },
      ""
    );
    await tx1.wait();
    console.log("Operator registered to Core EigenLayer contracts");
  } catch (error) {
    console.error("Error in registering as operator:", error);
  }

  // Generate signature for AVS registration
  const salt = ethers.hexlify(ethers.randomBytes(32));
  const expiry = Math.floor(Date.now() / 1000) + 3600;

  let operatorSignatureWithSaltAndExpiry = {
    signature: "",
    salt: salt,
    expiry: expiry,
  };

  // Calculate and sign digest hash
  const operatorDigestHash =
    await avsDirectory.calculateOperatorAVSRegistrationDigestHash(
      wallet.address,
      await irsManager.getAddress(),
      salt,
      expiry
    );

  const operatorSigningKey = new ethers.SigningKey(process.env.PRIVATE_KEY!);
  const operatorSignedDigestHash = operatorSigningKey.sign(operatorDigestHash);
  operatorSignatureWithSaltAndExpiry.signature = ethers.Signature.from(
    operatorSignedDigestHash
  ).serialized;

  // Register with AVS
  const tx2 = await ecdsaRegistryContract.registerOperatorWithSignature(
    operatorSignatureWithSaltAndExpiry,
    wallet.address
  );
  await tx2.wait();
  console.log("Operator registered on AVS successfully");
};

const verifyLoanPosition = async (
  user: string,
  pool: ethers.Contract,
  amount: bigint
): Promise<boolean> => {
  try {
    const { totalDebt, healthFactor } = await pool.getUserAccountData(user);
    return totalDebt >= amount && healthFactor >= MIN_HEALTH_FACTOR;
  } catch (error) {
    console.error("Error verifying loan position:", error);
    return false;
  }
};

const findMatchingSwap = async (request: any): Promise<number | null> => {
  try {
    const nextSwapId = await irsManager.nextSwapId();

    for (let i = 0; i < nextSwapId; i++) {
      const swap = await irsManager.swaps(i);

      if (
        !swap.matched &&
        swap.isActive &&
        swap.isPayingFixed !== request.isPayingFixed &&
        swap.notionalAmount === request.notionalAmount
      ) {
        return i;
      }
    }
    return null;
  } catch (error) {
    console.error("Error finding matching swap:", error);
    return null;
  }
};

const handleSwapValidation = async (task: any, taskIndex: number) => {
  console.log("\n=== Processing Swap Validation Task ===");
  const swapRequest = decodeSwapRequest(task.payload);
  console.log("\nSwap Request Details:", {
    user: swapRequest.user,
    notionalAmount: ethers.formatEther(swapRequest.notionalAmount) + " ETH",
    fixedRate: (Number(swapRequest.fixedRate) / 100).toString() + "%",
    direction: swapRequest.isPayingFixed
      ? "Variable → Fixed"
      : "Fixed → Variable",
    duration: Number(swapRequest.duration) / (24 * 60 * 60) + " days",
  });

  console.log("\nVerifying loan position...");
  const pool = swapRequest.isPayingFixed
    ? variableLendingPool
    : fixedLendingPool;
  const hasValidLoan = await verifyLoanPosition(
    swapRequest.user,
    pool,
    swapRequest.notionalAmount
  );

  if (!hasValidLoan) {
    console.log("❌ Invalid loan position:", {
      user: swapRequest.user,
      pool: swapRequest.isPayingFixed ? "Variable Pool" : "Fixed Pool",
    });
    return;
  }
  console.log("✅ Loan position verified successfully", {
    user: swapRequest.user,
    pool: swapRequest.isPayingFixed ? "Variable Pool" : "Fixed Pool",
  });

  console.log("\nSearching for matching swap...");
  const matchingSwapId = await findMatchingSwap(swapRequest);
  if (matchingSwapId !== null) {
    console.log("✅ Found matching swap:", { matchingSwapId });
  } else {
    console.log("ℹ️ No matching swap found, creating standalone swap");
  }

  console.log("\nSigning and submitting response...");
  await signAndRespondToTask(task, taskIndex, matchingSwapId);
};

const handleRateAndSettlement = async (task: any, taskIndex: number) => {
  console.log("\n=== Processing Rate and Settlement Task ===");
  const { swapsToSettle, proposedRate } = decodeRateData(task.payload);
  console.log("\nTask Details:", {
    swapsToSettle,
    proposedRate: (Number(proposedRate) / 1e27).toString() + "%",
  });

  console.log("\nValidating proposed rate...");
  const currentRate = await getCurrentRate();
  const isValidRate =
    Math.abs(Number(proposedRate) - Number(currentRate)) <= MAX_RATE_DEVIATION;

  if (!isValidRate) {
    console.log("❌ Invalid rate proposed:", {
      proposedRate: (Number(proposedRate) / 1e27).toString() + "%",
      currentRate: (Number(currentRate) / 1e27).toString() + "%",
      maxDeviation: (MAX_RATE_DEVIATION / 100).toString() + "%",
    });
    return;
  }
  console.log("✅ Rate validated successfully");

  console.log("\nSigning and submitting response...");
  await signAndRespondToTask(task, taskIndex);
};

const signAndRespondToTask = async (
  task: any,
  taskIndex: number,
  matchingSwapId?: number | null
) => {
  console.log("\n--- Signing Task Response ---");

  let messageData;
  if (task.taskType === TaskType.SWAP_VALIDATION) {
    messageData = [...decodeSwapRequest(task.payload), matchingSwapId || 0];
    console.log("Swap validation response data:", {
      taskIndex,
      matchingSwapId: matchingSwapId || "None",
    });
  } else {
    messageData = [...decodeRateData(task.payload)];
    console.log("Rate validation response data:", {
      taskIndex,
      swapsToSettle: messageData[0],
      rate: (Number(messageData[1]) / 1e27).toString() + "%",
    });
  }

  console.log("\nGenerating signature...");
  const messageHash = ethers.solidityPackedKeccak256(
    ["uint32", "uint8", "bytes"],
    [task.taskCreatedBlock, task.taskType, task.payload]
  );
  const messageBytes = ethers.getBytes(messageHash);
  const signature = await wallet.signMessage(messageBytes);

  console.log("\nSubmitting response to contract...");
  const tx = await irsManager.respondToTask(task, taskIndex, signature);
  console.log("Transaction hash:", tx.hash);
  const receipt = await tx.wait();
  console.log("✅ Response submitted successfully");
  console.log("Gas used:", receipt.gasUsed.toString());
};

const checkForSettlements = async () => {
  try {
    console.log("\n=== Checking for Due Settlements ===");
    const dueSwaps = await findDueSettlements();
    console.log("Due swaps found:", dueSwaps.length);

    if (dueSwaps.length === 0) return;

    console.log("\nDue Swaps:", dueSwaps);
    const currentRate = await getCurrentRate();
    console.log(
      "Current variable rate:",
      (Number(currentRate) / 1e27).toString() + "%"
    );

    console.log("\nCreating settlement task...");
    const tx = await irsManager.createNewTask(
      [TaskType.RATE_AND_SETTLEMENT, [dueSwaps, currentRate]],
      66,
      "0x"
    );
    console.log("Transaction hash:", tx.hash);
    const receipt = await tx.wait();
    console.log("✅ Settlement task created successfully");
    console.log("Gas used:", receipt.gasUsed.toString());
  } catch (error) {
    console.error("❌ Error checking settlements:", error);
  }
};

const getCurrentRate = async (): Promise<bigint> => {
  const [rate, ,] = await variableLendingPool.getReserveData();
  return rate;
};

const findDueSettlements = async (): Promise<number[]> => {
  const nextSwapId = await irsManager.nextSwapId();
  const dueSwaps: number[] = [];

  for (let i = 0; i < nextSwapId; i++) {
    const swap = await irsManager.swaps(i);
    if (
      swap.isActive &&
      swap.matched &&
      BigInt(Date.now()) / BigInt(1000) >=
        swap.lastSettlement + BigInt(SETTLEMENT_CHECK_INTERVAL)
    ) {
      dueSwaps.push(i);
    }
  }
  return dueSwaps;
};

const decodeSwapRequest = (payload: string): any => {
  const decoded = ethers.AbiCoder.defaultAbiCoder().decode(
    ["address", "uint256", "uint256", "bool", "uint256"],
    payload
  );
  return {
    user: decoded[0],
    notionalAmount: decoded[1],
    fixedRate: decoded[2],
    isPayingFixed: decoded[3],
    duration: decoded[4],
  };
};

const decodeRateData = (payload: string): any => {
  const decoded = ethers.AbiCoder.defaultAbiCoder().decode(
    ["uint256[]", "uint256"],
    payload
  );
  return {
    swapsToSettle: decoded[0],
    proposedRate: decoded[1],
  };
};

const main = async () => {
  try {
    await registerOperator();

    await irsManager.on(
      "NewTaskCreated",
      async (taskIndex: number, task: any) => {
        console.log("New task received", taskIndex, task);
        try {
          if (task.taskType === TaskType.SWAP_VALIDATION) {
            await handleSwapValidation(task, taskIndex);
          } else {
            await handleRateAndSettlement(task, taskIndex);
          }
        } catch (error) {
          console.error("Error handling task:", error);
        }
      }
    );

    setInterval(checkForSettlements, SETTLEMENT_CHECK_INTERVAL);

    console.log("Operator started successfully");
  } catch (error) {
    console.error("Error in main function:", error);
    throw error;
  }
};

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
