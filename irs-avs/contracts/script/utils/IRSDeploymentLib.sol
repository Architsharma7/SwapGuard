// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {ECDSAStakeRegistry} from "@eigenlayer-middleware/src/unaudited/ECDSAStakeRegistry.sol";
import {IRSServiceManager} from "../../src/IRSServiceManagerECDSA.sol";
import {IDelegationManager} from "@eigenlayer/contracts/interfaces/IDelegationManager.sol";
import {Quorum} from "@eigenlayer-middleware/src/interfaces/IECDSAStakeRegistryEventsAndErrors.sol";
import {UpgradeableProxyLib} from "./UpgradeableProxyLib.sol";
import {CoreDeploymentLib} from "./CoreDeploymentLib.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {MockVariableLendingPool} from "../../Mock-Lending/MockVariableLendingPool.sol";
import {MockFixedRateLendingPool} from "../../Mock-Lending/MockFixedRateLendingPool.sol";

library IRSDeploymentLib {
    using stdJson for *;
    using Strings for *;
    using UpgradeableProxyLib for address;

    Vm internal constant vm =
        Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    struct DeploymentData {
        address irsServiceManager;
        address stakeRegistry;
        address strategy;
        address token;
        address mockVariableLendingPool;
        address mockFixedLendingPool;
    }

    function deployContracts(
        address proxyAdmin,
        CoreDeploymentLib.DeploymentData memory core,
        Quorum memory quorum
    ) internal returns (DeploymentData memory) {
        DeploymentData memory result;

        // Deploy mock lending pools
        result.mockVariableLendingPool = address(
            new MockVariableLendingPool(proxyAdmin)
        );
        result.mockFixedLendingPool = address(
            new MockFixedRateLendingPool(proxyAdmin)
        );

        // Deploy upgradeable proxy contracts
        result.irsServiceManager = UpgradeableProxyLib.setUpEmptyProxy(
            proxyAdmin
        );
        result.stakeRegistry = UpgradeableProxyLib.setUpEmptyProxy(proxyAdmin);

        // Deploy implementations
        address stakeRegistryImpl = address(
            new ECDSAStakeRegistry(IDelegationManager(core.delegationManager))
        );

        address irsServiceManagerImpl = address(
            new IRSServiceManager(
                core.avsDirectory,
                result.stakeRegistry,
                core.delegationManager
            )
        );

        // Upgrade contracts
        bytes memory upgradeCall = abi.encodeCall(
            ECDSAStakeRegistry.initialize,
            (result.irsServiceManager, 0, quorum)
        );
        UpgradeableProxyLib.upgradeAndCall(
            result.stakeRegistry,
            stakeRegistryImpl,
            upgradeCall
        );

        bytes memory initCall = abi.encodeCall(
            IRSServiceManager.initialize,
            (proxyAdmin, proxyAdmin, proxyAdmin)
        );
        UpgradeableProxyLib.upgradeAndCall(
            result.irsServiceManager,
            irsServiceManagerImpl,
            initCall
        );

        return result;
    }

    function readDeploymentJson(
        uint256 chainId
    ) internal returns (DeploymentData memory) {
        return readDeploymentJson("deployments/", chainId);
    }

    function readDeploymentJson(
        string memory directoryPath,
        uint256 chainId
    ) internal returns (DeploymentData memory) {
        string memory fileName = string.concat(
            directoryPath,
            vm.toString(chainId),
            ".json"
        );
        require(vm.exists(fileName), "Deployment file does not exist");

        string memory json = vm.readFile(fileName);

        DeploymentData memory data;
        data.irsServiceManager = json.readAddress(
            ".contracts.irsServiceManager"
        );
        data.stakeRegistry = json.readAddress(".contracts.stakeRegistry");
        data.strategy = json.readAddress(".contracts.strategy");
        data.token = json.readAddress(".contracts.token");
        data.mockVariableLendingPool = json.readAddress(
            ".contracts.mockVariableLendingPool"
        );
        data.mockFixedLendingPool = json.readAddress(
            ".contracts.mockFixedLendingPool"
        );

        return data;
    }

    function writeDeploymentJson(DeploymentData memory data) internal {
        writeDeploymentJson("deployments/irs-avs/", block.chainid, data);
    }

    function writeDeploymentJson(
        string memory outputPath,
        uint256 chainId,
        DeploymentData memory data
    ) internal {
        address proxyAdmin = address(
            UpgradeableProxyLib.getProxyAdmin(data.irsServiceManager)
        );
        string memory deploymentData = _generateDeploymentJson(
            data,
            proxyAdmin
        );

        string memory fileName = string.concat(
            outputPath,
            vm.toString(chainId),
            ".json"
        );
        if (!vm.exists(outputPath)) {
            vm.createDir(outputPath, true);
        }

        vm.writeFile(fileName, deploymentData);
        console2.log("Deployment artifacts written to:", fileName);
    }

    function _generateDeploymentJson(
        DeploymentData memory data,
        address proxyAdmin
    ) private view returns (string memory) {
        return
            string.concat(
                '{"lastUpdate":{"timestamp":"',
                vm.toString(block.timestamp),
                '","block_number":"',
                vm.toString(block.number),
                '"},"addresses":',
                _generateContractsJson(data, proxyAdmin),
                "}"
            );
    }

    function _generateContractsJson(
        DeploymentData memory data,
        address proxyAdmin
    ) private view returns (string memory) {
        return
            string.concat(
                '{"proxyAdmin":"',
                proxyAdmin.toHexString(),
                '","irsServiceManager":"',
                data.irsServiceManager.toHexString(),
                '","irsServiceManagerImpl":"',
                data.irsServiceManager.getImplementation().toHexString(),
                '","stakeRegistry":"',
                data.stakeRegistry.toHexString(),
                '","stakeRegistryImpl":"',
                data.stakeRegistry.getImplementation().toHexString(),
                '","strategy":"',
                data.strategy.toHexString(),
                '","token":"',
                data.token.toHexString(),
                '","mockVariableLendingPool":"',
                data.mockVariableLendingPool.toHexString(),
                '","mockFixedLendingPool":"',
                data.mockFixedLendingPool.toHexString(),
                '"}'
            );
    }
}
