// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {Chainvoice} from "../src/Chainvoice.sol";
import {DeployChainvoice} from "../script/Chainvoice.s.sol";

contract DeployChainvoiceTest is Test {
    address constant FEE_ADDRESS = address(0x999);
    string constant FEE_ADDRESS_STR = "0x0000000000000000000000000000000000000999";

    // vm.setEnv changes the environment of the whole process, which forge
    // shares between tests running in parallel, so every scenario runs here
    // in sequence rather than in separate test functions.
    function testRun_AppliesEnvSettings() public {
        DeployChainvoice script = new DeployChainvoice();

        // FEE_WEI blank (as in .env.example): the default fee.
        _setEnv(FEE_ADDRESS_STR, "");
        Chainvoice c = script.run();
        assertEq(c.feeAddress(), FEE_ADDRESS);
        assertEq(c.fee(), 0.0005 ether);

        // Both set.
        _setEnv(FEE_ADDRESS_STR, "1000000000000000");
        c = script.run();
        assertEq(c.feeAddress(), FEE_ADDRESS);
        assertEq(c.fee(), 0.001 ether);

        // An explicit zero fee is a fee, not "unset".
        _setEnv(FEE_ADDRESS_STR, "0");
        c = script.run();
        assertEq(c.fee(), 0);

        // The fee address is the only account that can configure the contract.
        vm.prank(FEE_ADDRESS);
        c.setFeeAmount(1);
        assertEq(c.fee(), 1);

        // A blank FEE_ADDRESS is not a deployable config: the constructor
        // rejects the zero address (or parsing fails first).
        _setEnv("", "");
        vm.expectRevert();
        script.run();
    }

    function _setEnv(string memory feeAddress, string memory feeWei) private {
        vm.setEnv("FEE_ADDRESS", feeAddress);
        vm.setEnv("FEE_WEI", feeWei);
    }
}
