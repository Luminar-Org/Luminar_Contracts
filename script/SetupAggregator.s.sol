// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {DexAggregatorGateway} from "../src/DexAppGateway.sol";
import {DexAggregatorDeployer} from "../src/DexDeployer.sol";
import {FeesData} from "lib/socket-protocol/contracts/common/Structs.sol";
import {ETH_ADDRESS} from "lib/socket-protocol/contracts/common/Constants.sol";

contract SetupDexAggregator is Script {
    function run() public {
        // Get environment variables
        address addressResolver = vm.envAddress("ADDRESS_RESOLVER");
        string memory rpc = vm.envString("SOCKET_RPC");
        vm.createSelectFork(rpc);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // Setting fee payment on Ethereum Sepolia
        FeesData memory feesData = FeesData({
            feePoolChain: 11155111, // Sepolia chain slug
            feePoolToken: ETH_ADDRESS,
            maxFees: 0.01 ether
        });

        // Initialize supported chain slugs
        uint32[] memory initialChainSlugs = new uint32[](5);
        initialChainSlugs[0] = 11155111; // Sepolia
        initialChainSlugs[1] = 84532; // Base Testnet
        initialChainSlugs[2] = 421614; // Arbitrum Testnet
        initialChainSlugs[3] = 11155420; // Optimism Testnet
        initialChainSlugs[4] = 7625382; // offchainVM

        // Deploy DexAggregator Deployer
        DexAggregatorDeployer dexDeployer = new DexAggregatorDeployer(
            addressResolver,
            feesData
        );

        // Deploy DexAggregator Gateway
        DexAggregatorGateway dexGateway = new DexAggregatorGateway(
            addressResolver,
            address(dexDeployer),
            feesData,
            initialChainSlugs
        );

        // Log deployed addresses
        console.log("DexAggregatorDeployer: ", address(dexDeployer));
        console.log("DexAggregatorGateway: ", address(dexGateway));

        vm.stopBroadcast();
    }
}
