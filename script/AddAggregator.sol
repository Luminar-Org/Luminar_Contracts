// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {DexAggregatorGateway} from "../src/DexAppGateway.sol";

contract ExecuteTrades is Script {
    // Test data for multiple chains and DEXes
    uint32[] chainSlugs = [
        11155111, // Sepolia
        421614 // Arbitrum Testnet
    ];

    // Example DEX routers on different chains
    address[] routers1 = [
        0x2CB45Edb4517d5947aFdE3BEAbF95A582506858B,
        0xA1B1742e9c32C7cAa9726d8204bD5715e3419861
    ];

    address[] routers2 = [
        0x2CB45Edb4517d5947aFdE3BEAbF95A582506858B,
        0xA1B1742e9c32C7cAa9726d8204bD5715e3419861
    ];

    // Example test tokens on different chains
    address[] tokens1 = [
        0xC9BdeEd33CD01541e1eeD10f90519d2C06Fe3feB,
        0xB12BFcA5A55806AaF64E99521918A4bf0fC40802
    ];

    address[] tokens2 = [
        0xC9BdeEd33CD01541e1eeD10f90519d2C06Fe3feB,
        0xB12BFcA5A55806AaF64E99521918A4bf0fC40802
    ];

    uint256[] amounts = [
        10000, // 1 USDC (6 decimals)
        10000 // 1 USDC
    ];

    function run() public {
        string memory rpc = vm.envString("SOCKET_RPC");
        vm.createSelectFork(rpc);
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        DexAggregatorGateway dexGateway = DexAggregatorGateway(
            vm.envAddress("DEX_APP_GATEWAY")
        );

        console.log("Adding chain instances...");
        for (uint i = 0; i < chainSlugs.length; i++) {
            if (dexGateway.getChainInstanceCount(chainSlugs[i]) == 0) {
                address[] memory instances = new address[](1);
                // You'll need to replace this with actual deployed instance addresses
                instances[0] = address(
                    0x419CEF3D12bd945a47956eC94525754E1B117A84
                );
                dexGateway.addChainInstances(chainSlugs[i], instances);
            }
        }

        console.log("Testing single chain trade on Sepolia...");
        dexGateway.executeDualDexTrade(
            chainSlugs[0],
            routers1[0],
            routers2[0],
            tokens1[0],
            tokens2[0],
            amounts[0]
        );

        // Third: Test batch trades across chains
        console.log("Testing batch trades across chains...");
        dexGateway.executeBatchDualDexTrades(
            chainSlugs,
            routers1,
            routers2,
            tokens1,
            tokens2,
            amounts
        );

        vm.stopBroadcast();
        console.log("All test trades completed");
    }

    // Helper function to estimate profits before execution
    function estimateTrades() public view {
        DexAggregatorGateway dexGateway = DexAggregatorGateway(
            vm.envAddress("DEX_GATEWAY_ADDRESS")
        );

        for (uint i = 0; i < chainSlugs.length; i++) {
            console.log("Checking trade viability for chain:", chainSlugs[i]);
            try dexGateway.getChainInstanceCount(chainSlugs[i]) returns (
                uint256 count
            ) {
                console.log("Number of instances on chain:", count);
                if (count > 0) {
                    console.log("Chain is ready for trading");
                } else {
                    console.log("No instances available on chain");
                }
            } catch {
                console.log("Error checking chain:", chainSlugs[i]);
            }
        }
    }
}
