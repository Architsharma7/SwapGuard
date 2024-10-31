// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/Test.sol";
import {IRSDeploymentLib} from "./utils/IRSDeploymentLib.sol";
import {CoreDeploymentLib} from "./utils/CoreDeploymentLib.sol";
import {UpgradeableProxyLib} from "./utils/UpgradeableProxyLib.sol";
import {StrategyBase} from "@eigenlayer/contracts/strategies/StrategyBase.sol";
import {ERC20Mock} from "../test/ERC20Mock.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {StrategyFactory} from "@eigenlayer/contracts/strategies/StrategyFactory.sol";
import {StrategyManager} from "@eigenlayer/contracts/core/StrategyManager.sol";

import {Quorum, StrategyParams, IStrategy} from "@eigenlayer-middleware/src/interfaces/IECDSAStakeRegistryEventsAndErrors.sol";

contract IRSDeployer is Script {
    using CoreDeploymentLib for *;
    using UpgradeableProxyLib for address;

    address private deployer;
    address proxyAdmin;
    IStrategy irsStrategy;
    CoreDeploymentLib.DeploymentData coreDeployment;
    IRSDeploymentLib.DeploymentData irsDeployment;
    Quorum internal quorum;
    ERC20Mock token;

    function setUp() public virtual {
        // Load deployer key
        deployer = vm.rememberKey(vm.envUint("PRIVATE_KEY"));
        vm.label(deployer, "Deployer");

        // Read core deployment data
        coreDeployment = CoreDeploymentLib.readDeploymentJson(
            "deployments/core/",
            block.chainid
        );

        // Deploy mock token and strategy
        token = new ERC20Mock();
        irsStrategy = IStrategy(
            StrategyFactory(coreDeployment.strategyFactory).deployNewStrategy(
                token
            )
        );

        // Set up quorum with strategy
        quorum.strategies.push(
            StrategyParams({strategy: irsStrategy, multiplier: 10_000})
        );
    }

    function run() external {
        vm.startBroadcast(deployer);

        // Deploy proxy admin
        proxyAdmin = UpgradeableProxyLib.deployProxyAdmin();

        // Deploy IRS contracts
        irsDeployment = IRSDeploymentLib.deployContracts(
            proxyAdmin,
            coreDeployment,
            quorum
        );

        // Set strategy and token addresses
        irsDeployment.strategy = address(irsStrategy);
        irsDeployment.token = address(token);

        vm.stopBroadcast();

        // Verify deployment
        verifyDeployment();

        // Write deployment data
        IRSDeploymentLib.writeDeploymentJson(irsDeployment);
    }

    function verifyDeployment() internal view {
        require(
            irsDeployment.stakeRegistry != address(0),
            "StakeRegistry address cannot be zero"
        );
        require(
            irsDeployment.irsServiceManager != address(0),
            "IRSServiceManager address cannot be zero"
        );
        require(
            irsDeployment.mockVariableLendingPool != address(0),
            "MockVariableLendingPool address cannot be zero"
        );
        require(
            irsDeployment.mockFixedLendingPool != address(0),
            "MockFixedLendingPool address cannot be zero"
        );
        require(
            irsDeployment.strategy != address(0),
            "Strategy address cannot be zero"
        );
        require(proxyAdmin != address(0), "ProxyAdmin address cannot be zero");
        require(
            coreDeployment.delegationManager != address(0),
            "DelegationManager address cannot be zero"
        );
        require(
            coreDeployment.avsDirectory != address(0),
            "AVSDirectory address cannot be zero"
        );
    }
}
