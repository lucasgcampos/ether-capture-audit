// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {RetirementFundChallenge} from "../src/RetirementFundChallenge.sol";

contract CounterTest is Test {
    RetirementFundChallenge public retirementFund;
    
    address constant owner = address(0x11);
    address constant beneficiary = address(0x22);

    function setUp() public {
        retirementFund = new RetirementFundChallenge(beneficiary);
    }
}
