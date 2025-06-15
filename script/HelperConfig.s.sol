//SPDX-License-Identifier: MIT

// deploy mocks when we are on a local anvil chain
//  keep track of contract address accross diffrent chains
// sepolia ETH/USD
// mainnet ETH/USD

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // if we are on a local anvil, we deploy mocks
    // otherwise, grab the existing address from the live network
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = int256(2000 * 10 ** 8);
    //2000.00000000

    struct NetworkConfig {
        address pricefeed; //ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        //price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            pricefeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        //price feed address
        NetworkConfig memory ethConfig = NetworkConfig({
            pricefeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.pricefeed != address(0)) {
            return activeNetworkConfig; //if we have a price feed address, return it
        }
        //price feed address

        //deploy the mocks
        // return the mocks address

        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({
            pricefeed: address(mockV3Aggregator)
        });
        return anvilConfig;
    }
}
