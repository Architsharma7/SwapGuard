const fs = require("fs");
const path = require("path");

const abiDir = "abis";
const contractsDir = "contracts";
const artifactsDir = path.join(contractsDir, "out");

const contractsToExtract = [
  { name: "IAVSDirectory", path: "IAVSDirectory.sol" },
  { name: "IDelegationManager", path: "IDelegationManager.sol" },
  { name: "ECDSAStakeRegistry", path: "ECDSAStakeRegistry.sol" },
  { name: "IRSServiceManager", path: "IRSServiceManagerECDSA.sol" },
  {
    name: "MockVariableLendingPool",
    path: "MockVariableLendingPool.sol",
  },
  {
    name: "MockFixedRateLendingPool",
    path: "MockFixedRateLendingPool.sol",
  },
];

if (!fs.existsSync(abiDir)) {
  fs.mkdirSync(abiDir);
}

function checkArtifactsDirectory() {
  if (!fs.existsSync(artifactsDir)) {
    console.error(`The artifacts directory '${artifactsDir}' does not exist.`);
    console.log('Please compile your contracts first using "forge build"');
    process.exit(1);
  }

  const files = fs.readdirSync(artifactsDir);
  if (files.length === 0) {
    console.error(`The artifacts directory '${artifactsDir}' is empty.`);
    console.log(
      'Please compile your contracts first using "forge build" or confirm the path is correct.'
    );
    process.exit(1);
  }
}

function extractAbi(contract) {
  const outputPath = path.join(
    artifactsDir,
    contract.path,
    `${contract.name}.json`
  );
  const abiOutputPath = path.join(abiDir, `${contract.name}.json`);

  try {
    const contractData = JSON.parse(fs.readFileSync(outputPath, "utf8"));
    const abi = JSON.stringify(contractData.abi, null, 2);
    fs.writeFileSync(abiOutputPath, abi);
    console.log(`Extracted ABI for ${contract.name}`);
  } catch (error) {
    console.error(`Error extracting ABI for ${contract.name}:`, error.message);
  }
}

checkArtifactsDirectory();

for (const contract of contractsToExtract) {
  extractAbi(contract);
}

console.log(
  'ABI extraction complete. Check the "abis" directory for the output.'
);
