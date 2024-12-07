// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

import "./DexAggregator.sol";
import "lib/socket-protocol/contracts/base/AppDeployerBase.sol";

contract DexAggregatorDeployer is AppDeployerBase {
    // Create unique identifier for the DexAggregator contract
    bytes32 public dexAggregator = _createContractId("dexAggregator");

    constructor(
        address addressResolver_,
        FeesData memory feesData_
    ) AppDeployerBase(addressResolver_) {
        // Encode the creation code for DexAggregator
        creationCodeWithArgs[dexAggregator] = abi.encodePacked(
            type(DexAggregator).creationCode
        );

        // Set fees data for the protocol
        _setFeesData(feesData_);
    }

    /**
     * @dev Deploys the DexAggregator contract to the specified chain
     * @param chainSlug The unique identifier for the target chain
     */
    function deployContracts(uint32 chainSlug) external async {
        _deploy(dexAggregator, chainSlug);
    }

    /**
     * @dev Initialize function required by Socket Protocol
     * @param chainSlug The unique identifier for the target chain
     */
    function initialize(uint32 chainSlug) public override async {}
}
