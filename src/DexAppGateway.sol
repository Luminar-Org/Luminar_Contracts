// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "lib/socket-protocol/contracts/base/AppGatewayBase.sol";
import "lib/socket-protocol/contracts/utils/Ownable.sol";
import "./DexAggregator.sol";

contract DexAggregatorGateway is AppGatewayBase, Ownable {
    // Track the last used instance index for round-robin
    uint256 private currentInstanceIndex;

    // Store chain slugs for supported networks
    uint32[] public supportedChainSlugs;

    // Mapping to store DexAggregator instances for each chain
    mapping(uint32 => address[]) public chainInstances;

    event ArbitrageExecuted(
        uint32 chainSlug,
        address instance,
        address router1,
        address router2,
        address token1,
        address token2,
        uint256 amount
    );

    constructor(
        address _addressResolver,
        address deployerContract_,
        FeesData memory feesData_,
        uint32[] memory initialChainSlugs_
    ) AppGatewayBase(_addressResolver) Ownable(msg.sender) {
        addressResolver.setContractsToGateways(deployerContract_);
        _setFeesData(feesData_);

        // Initialize supported chains
        for (uint i = 0; i < initialChainSlugs_.length; i++) {
            supportedChainSlugs.push(initialChainSlugs_[i]);
        }
    }

    /**
     * @dev Add instances for a specific chain
     * @param chainSlug The chain identifier
     * @param instances Array of DexAggregator addresses on that chain
     */
    function addChainInstances(
        uint32 chainSlug,
        address[] memory instances
    ) external onlyOwner {
        require(isChainSupported(chainSlug), "Chain not supported");
        for (uint i = 0; i < instances.length; i++) {
            chainInstances[chainSlug].push(instances[i]);
        }
    }

    /**
     * @dev Execute arbitrage trade using round-robin across instances
     */
    function executeDualDexTrade(
        uint32 chainSlug,
        address router1,
        address router2,
        address token1,
        address token2,
        uint256 amount
    ) public async {
        require(isChainSupported(chainSlug), "Chain not supported");
        require(chainInstances[chainSlug].length > 0, "No instances for chain");

        // Get next instance using round-robin
        address instance = getNextInstance(chainSlug);

        // Execute trade on the selected instance
        DexAggregator(payable(instance)).dualDexTrade(
            router1,
            router2,
            token1,
            token2,
            amount
        );

        emit ArbitrageExecuted(
            chainSlug,
            instance,
            router1,
            router2,
            token1,
            token2,
            amount
        );
    }

    /**
     * @dev Execute batch arbitrage trades across multiple chains
     */
    function executeBatchDualDexTrades(
        uint32[] memory chainSlugs,
        address[] memory routers1,
        address[] memory routers2,
        address[] memory tokens1,
        address[] memory tokens2,
        uint256[] memory amounts
    ) external async {
        require(
            chainSlugs.length == routers1.length &&
                chainSlugs.length == routers2.length &&
                chainSlugs.length == tokens1.length &&
                chainSlugs.length == tokens2.length &&
                chainSlugs.length == amounts.length,
            "Array lengths mismatch"
        );

        for (uint i = 0; i < chainSlugs.length; i++) {
            executeDualDexTrade(
                chainSlugs[i],
                routers1[i],
                routers2[i],
                tokens1[i],
                tokens2[i],
                amounts[i]
            );
        }
    }

    /**
     * @dev Get the next instance using round-robin
     */
    function getNextInstance(uint32 chainSlug) internal returns (address) {
        address[] storage instances = chainInstances[chainSlug];
        require(instances.length > 0, "No instances available");

        uint256 index = currentInstanceIndex % instances.length;
        currentInstanceIndex++;

        return instances[index];
    }

    /**
     * @dev Check if a chain is supported
     */
    function isChainSupported(uint32 chainSlug) public view returns (bool) {
        for (uint i = 0; i < supportedChainSlugs.length; i++) {
            if (supportedChainSlugs[i] == chainSlug) return true;
        }
        return false;
    }

    /**
     * @dev Get number of instances for a chain
     */
    function getChainInstanceCount(
        uint32 chainSlug
    ) external view returns (uint256) {
        return chainInstances[chainSlug].length;
    }

    /**
     * @dev Update fees configuration
     */
    function setFees(FeesData memory feesData_) public onlyOwner {
        feesData = feesData_;
    }

    /**
     * @dev Add new supported chain
     */
    function addSupportedChain(uint32 chainSlug) external onlyOwner {
        require(!isChainSupported(chainSlug), "Chain already supported");
        supportedChainSlugs.push(chainSlug);
    }
}
