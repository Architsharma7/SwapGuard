import { ethers } from "ethers";
import * as dotenv from "dotenv";
const fs = require("fs");
const path = require("path");
dotenv.config();

if (!Object.keys(process.env).length) {
  throw new Error("process.env object is empty");
}

enum TaskType {
  SWAP_VALIDATION,
  RATE_AND_SETTLEMENT,
}

const SETTLEMENT_CHECK_INTERVAL = 24000; // ms
const MIN_HEALTH_FACTOR = 150; // 150%
const MAX_RATE_DEVIATION = 200; // 2%

const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY!, provider);
let chainId = 31337;

const avsDeploymentData = JSON.parse(
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
const variableLendingPoolAddress =
  avsDeploymentData.addresses.mockVariableLendingPool;
const fixedLendingPoolAddress =
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
const variableLendingPoolABI = JSON.parse(
  fs.readFileSync(
    path.resolve(__dirname, "../abis/MockVariableLendingPool.json"),
    "utf8"
  )
);
const fixedLendingPoolABI = JSON.parse(
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
const irsManager = new ethers.Contract(
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
const variableLendingPool = new ethers.Contract(
  variableLendingPoolAddress,
  variableLendingPoolABI,
  provider
);
const fixedLendingPool = new ethers.Contract(
  fixedLendingPoolAddress,
  fixedLendingPoolABI,
  provider
);

const registerOperator = async () => {
  try {
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
  const swapRequest = decodeSwapRequest(task.payload);
  console.log("Processing swap validation", swapRequest);

  const hasValidLoan = await verifyLoanPosition(
    swapRequest.user,
    swapRequest.isPayingFixed ? variableLendingPool : fixedLendingPool,
    swapRequest.notionalAmount
  );

  if (!hasValidLoan) {
    console.warn("Invalid loan position", { user: swapRequest.user });
    return;
  }

  const matchingSwapId = await findMatchingSwap(swapRequest);

  await signAndRespondToTask(task, taskIndex, matchingSwapId);
};

const handleRateAndSettlement = async (task: any, taskIndex: number) => {
  const { swapsToSettle, proposedRate } = decodeRateData(task.payload);
  console.log("Processing rate and settlement", {
    swapsToSettle,
    proposedRate,
  });

  const currentRate = await getCurrentRate();
  const isValidRate =
    Math.abs(Number(proposedRate) - Number(currentRate)) <= MAX_RATE_DEVIATION;

  if (!isValidRate) {
    console.warn("Invalid rate proposed", { proposedRate, currentRate });
    return;
  }

  await signAndRespondToTask(task, taskIndex);
};

const signAndRespondToTask = async (
  task: any,
  taskIndex: number,
  matchingSwapId?: number | null
) => {
  let messageData;
  if (task.taskType === TaskType.SWAP_VALIDATION) {
    messageData = [...decodeSwapRequest(task.payload), matchingSwapId || 0];
  } else {
    messageData = [...decodeRateData(task.payload)];
  }

  const messageHash = ethers.solidityPackedKeccak256(
    ["uint32", "uint8", "bytes"],
    [task.taskCreatedBlock, task.taskType, task.payload]
  );
  const messageBytes = ethers.getBytes(messageHash);
  const signature = await wallet.signMessage(messageBytes);

  const operators = [await wallet.getAddress()];
  const signatures = [signature];
  const signedTask = ethers.AbiCoder.defaultAbiCoder().encode(
    ["address[]", "bytes[]", "uint32"],
    [
      operators,
      signatures,
      ethers.toBigInt((await provider.getBlockNumber()) - 1),
    ]
  );

  const tx = await irsManager.respondToTask(task, taskIndex, signedTask);
  await tx.wait();
  console.log("Responded to task", taskIndex);
};

const checkForSettlements = async () => {
  try {
    const dueSwaps = await findDueSettlements();
    if (dueSwaps.length === 0) return;

    const currentRate = await getCurrentRate();
    const taskData = ethers.AbiCoder.defaultAbiCoder().encode(
      ["uint8", "tuple(uint256[],uint256)"],
      [TaskType.RATE_AND_SETTLEMENT, [dueSwaps, currentRate]]
    );

    const tx = await irsManager.createNewTask(
      taskData,
      66, // quorumThresholdPercentage
      "0x" // quorumNumbers - empty for ECDSA
    );
    await tx.wait();
    console.log("Created settlement task");
  } catch (error) {
    console.error("Error checking settlements:", error);
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
