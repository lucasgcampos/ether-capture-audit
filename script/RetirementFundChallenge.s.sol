// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {RetirementFundChallenge} from "../src/RetirementFundChallenge.sol";

contract RetirementFundChallengeScript is Script {
    
    address beneficiary = address(0x11);
    RetirementFundChallenge public retirementFundChallenge;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        retirementFundChallenge = new RetirementFundChallenge(beneficiary);

        vm.stopBroadcast();
    }
}
