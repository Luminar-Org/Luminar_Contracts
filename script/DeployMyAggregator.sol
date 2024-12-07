// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {DexAggregatorDeployer} from "../src/DexDeployer.sol";

contract DeployDexAggregator is Script {
    function run() public {
        // Get RPC and private key from environment
        string memory rpc = vm.envString("SOCKET_RPC");
        vm.createSelectFork(rpc);
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Get deployer address from environment or use a constant
        address deployerAddress = vm.envAddress("DEX_DEPLOYER");

        // Initialize the deployer contract
        DexAggregatorDeployer dexDeployer = DexAggregatorDeployer(
            deployerAddress
        );

        // Deploy to multiple chains
        // Sepolia
        console.log("Deploying to Sepolia...");
        dexDeployer.deployContracts(11155111);
        console.log("Deployed to Sepolia");

        // Base Testnet
        console.log("Deploying to Base Testnet...");
        dexDeployer.deployContracts(84532);
        console.log("Deployed to Base Testnet");

        // Arbitrum Testnet
        console.log("Deploying to Arbitrum Testnet...");
        dexDeployer.deployContracts(421614);
        console.log("Deployed to Arbitrum Testnet");

        // Optimism Testnet
        console.log("Deploying to Optimism Testnet...");
        dexDeployer.deployContracts(11155420);
        console.log("Deployed to Optimism Testnet");

        // OffchainVM
        console.log("Deploying to OffchainVM...");
        dexDeployer.deployContracts(7625382);
        console.log("Deployed to OffchainVM");

        vm.stopBroadcast();
        console.log("All deployments completed");
    }
}
