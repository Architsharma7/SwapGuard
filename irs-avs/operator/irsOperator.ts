import { ethers } from "ethers";
import * as dotenv from "dotenv";
const fs = require("fs");
const path = require("path");
dotenv.config();

export enum TaskType {
  SWAP_VALIDATION,
  MATCH_VALIDATION,
  SETTLEMENT,
}

const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY!, provider);
const chainId = 31337;
const MIN_HEALTH_FACTOR = 150; // 150%
const MAX_RATE_DEVIATION = 200; // 2% (in basis points)

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

async function registerOperator() {
  try {
    const isAlreadyRegistered = await delegationManager.isOperator(
      wallet.address
    );
    if (isAlreadyRegistered) {
      console.log("Operator already registered");
      return;
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

    const salt = ethers.hexlify(ethers.randomBytes(32));
    const expiry = Math.floor(Date.now() / 1000) + 3600;

    const operatorDigestHash =
      await avsDirectory.calculateOperatorAVSRegistrationDigestHash(
        wallet.address,
        await irsManager.getAddress(),
        salt,
        expiry
      );

    const operatorSigningKey = new ethers.SigningKey(process.env.PRIVATE_KEY!);
    const operatorSignedDigestHash =
      operatorSigningKey.sign(operatorDigestHash);
    const operatorSignature = ethers.Signature.from(
      operatorSignedDigestHash
    ).serialized;

    const tx2 = await ecdsaRegistryContract.registerOperatorWithSignature(
      { signature: operatorSignature, salt, expiry },
      wallet.address
    );
    await tx2.wait();
    console.log("Operator registered on AVS successfully");
  } catch (error) {
    console.error("Error in registering as operator:", error);
  }
}

function startListening() {
  irsManager.on("NewTaskCreated", async (taskIndex: number, task: any) => {
    console.log("\nNew task received:", {
      taskIndex,
      type: TaskType[task.taskType],
      blockNumber: task.taskCreatedBlock,
    });

    console.log("Task payload:", task.payload);
    try {
      if (Number(task.taskType) === TaskType.SWAP_VALIDATION) {
        console.log("performing swap validation");
        await handleSwapValidation(task, taskIndex);
      } else if (Number(task.taskType) === TaskType.MATCH_VALIDATION) {
        await handleMatchValidation(task, taskIndex);
      } else if (Number(task.taskType) === TaskType.SETTLEMENT) {
        await handleSettlement(task, taskIndex);
      }
    } catch (error) {
      console.error("Error handling task:", error);
    }
  });

  console.log("Listening for tasks...");
}

async function handleSwapValidation(task: any, taskIndex: number) {
  console.log("\n=== Processing Swap Validation Task ===");
  const { user, notionalAmount, fixedRate, isPayingFixed, duration, margin } =
    await decodeSwapRequest(task.payload);

  console.log("Swap Request Details:", {
    user,
    notionalAmount: ethers.formatEther(notionalAmount),
    fixedRate: (Number(fixedRate) / 100).toString() + "%",
    isPayingFixed,
    duration: Number(duration) / (24 * 60 * 60) + " days",
    margin: ethers.formatEther(margin),
  });

  // const pool = isPayingFixed ? variableLendingPool : fixedLendingPool;
  // const isValid = await verifyLoanPosition(user, pool, notionalAmount);

  // if (isValid) {
  // console.log("✅ Valid loan position");
  await signAndRespondToTask(task, taskIndex);
  // } else {
  // console.log("❌ Invalid loan position");
  // }
}

async function handleMatchValidation(task: any, taskIndex: number) {
  const { swap1Id, swap2Id, matcher } = await decodeMatchRequest(task.payload);
  const swap1 = await irsManager.getSwap(swap1Id);
  const swap2 = await irsManager.getSwap(swap2Id);
  const isValid = await validateMatch(swap1, swap2);

  const responsePayload = ethers.AbiCoder.defaultAbiCoder().encode(
    ["uint256", "uint256", "bool", "address"],
    // TODO: change to isValid
    [swap1Id, swap2Id, true, matcher]
  );

  await signAndRespondToTask(task, taskIndex, responsePayload);
}

async function handleSettlement(task: any, taskIndex: number) {
  console.log("\n=== Processing Settlement Task ===");
  const { swapsToSettle, settler } = await decodeSettlementRequest(
    task.payload
  );

  console.log("Settlement Request Details:", {
    swapsToSettle,
    settler,
  });

  const [, currentRate] = await variableLendingPool.getReserveData();
  console.log(
    "Current variable rate:",
    (Number(currentRate) / 1e27).toString() + "%"
  );

  const validationResults = await Promise.all(
    swapsToSettle.map(async (swapId: number) => {
      return validateSettlement(swapId);
    })
  );

  const responsePayload = ethers.AbiCoder.defaultAbiCoder().encode(
    ["uint256[]", "uint256", "bool[]", "address"],
    [swapsToSettle, currentRate, validationResults, settler]
  );

  await signAndRespondToTask(task, taskIndex, responsePayload);
}

async function signAndRespondToTask(
  task: any,
  taskIndex: number,
  modifiedPayload?: string
) {
  const payload = modifiedPayload || task.payload;
  const messageHash = ethers.solidityPackedKeccak256(
    ["uint32", "uint8", "bytes"],
    [task.taskCreatedBlock, task.taskType, payload]
  );

  const messageBytes = ethers.getBytes(messageHash);
  const signature = await wallet.signMessage(messageBytes);

  const tx = await irsManager.respondToTask(
    {
      taskCreatedBlock: task.taskCreatedBlock,
      taskType: task.taskType,
      payload,
    },
    taskIndex,
    signature
  );

  console.log("Response submitted. Transaction hash:", tx.hash);
  await tx.wait();
}

const getCurrentRate = async () => {
  const [, rate] = await variableLendingPool.getReserveData();
  return rate;
};

const decodeSwapRequest = async (payload: string) => {
  const decoded = ethers.AbiCoder.defaultAbiCoder().decode(
    ["address", "uint256", "uint256", "bool", "uint256", "uint256"],
    payload
  );
  return {
    user: decoded[0],
    notionalAmount: decoded[1],
    fixedRate: decoded[2],
    isPayingFixed: decoded[3],
    duration: decoded[4],
    margin: decoded[5],
  };
};

const decodeMatchRequest = async (payload: string) => {
  const decoded = ethers.AbiCoder.defaultAbiCoder().decode(
    ["uint256", "uint256", "address"],
    payload
  );
  console.log("Match Request Details:", {
    swap1Id: decoded[0],
    swap2Id: decoded[1],
    matcher: decoded[2],
  });

  return {
    swap1Id: decoded[0],
    swap2Id: decoded[1],
    matcher: decoded[2],
  };
};

const decodeSettlementRequest = async (payload: string) => {
  const decoded = ethers.AbiCoder.defaultAbiCoder().decode(
    ["uint256[]", "address"],
    payload
  );
  return {
    swapsToSettle: decoded[0],
    settler: decoded[1],
  };
};

const verifyLoanPosition = async (
  user: string,
  pool: ethers.Contract,
  amount: bigint
) => {
  try {
    const { totalDebt, healthFactor } = await pool.getUserAccountData(user);
    return totalDebt >= amount && healthFactor >= MIN_HEALTH_FACTOR;
  } catch (error) {
    console.error("Error verifying loan position:", error);
    return false;
  }
};

const validateMatch = async (swap1: any, swap2: any) => {
  return (
    !swap1.matched &&
    !swap2.matched &&
    swap1.isActive &&
    swap2.isActive &&
    swap1.notionalAmount === swap2.notionalAmount &&
    swap1.fixedRate === swap2.fixedRate &&
    swap1.isPayingFixed !== swap2.isPayingFixed
  );
};

const validateSettlement = async (swapId: number) => {
  try {
    const canSettle = await irsManager.canBeSettled(swapId);
    if (!canSettle) {
      console.log(`Swap ${swapId} cannot be settled yet`);
      return false;
    }
    return true;
  } catch (error) {
    console.error("Error validating settlement:", error);
    return false;
  }
};

async function startOperator() {
  await registerOperator();
  startListening();
}

startOperator().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
