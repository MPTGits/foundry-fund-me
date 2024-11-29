// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    //If we are on a local network we deploy the mocks and we use the mocks

    struct NetworkConfig {
        address priceFeed;
    }

    NetworkConfig public currentNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 200e8;

    constructor() {
        if (block.chainid == 11155111) {
            currentNetworkConfig = getSepoliaEthConfig();
        } else {
            currentNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return
            NetworkConfig({
                priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (currentNetworkConfig.priceFeed != address(0)) {
            return currentNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        return NetworkConfig({priceFeed: address(mockPriceFeed)});
    }
}
