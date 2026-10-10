// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Chainvoice} from "../src/Chainvoice.sol";
import {Script, console} from "../lib/forge-std/src/Script.sol";

/// Deploys Chainvoice with its fee settings fixed at construction.
///
///   FEE_ADDRESS  receives withdrawn fees and is the only address that can
///                change the fee or the fee address (required, non-zero)
///   FEE_WEI      native fee per paid invoice (optional; 0 is a valid fee,
///                unset or blank uses the 0.0005 ether default)
contract DeployChainvoice is Script {
    uint256 internal constant DEFAULT_FEE = 0.0005 ether;

    function run() external returns (Chainvoice c) {
        // Read as strings so a blank line in .env (as in .env.example) counts
        // as unset instead of failing to parse.
        string memory feeAddress = vm.envString("FEE_ADDRESS");
        string memory feeWei = vm.envOr("FEE_WEI", string(""));

        uint256 fee = bytes(feeWei).length != 0 ? vm.parseUint(feeWei) : DEFAULT_FEE;

        vm.startBroadcast();
        c = new Chainvoice(fee, vm.parseAddress(feeAddress));
        vm.stopBroadcast();

        console.log("Chainvoice deployed at", address(c));
        console.log("feeAddress", c.feeAddress());
        console.log("fee (wei)", c.fee());
    }
}
