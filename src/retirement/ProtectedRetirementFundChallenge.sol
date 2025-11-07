// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ProtectedRetirementFundChallenge {
    
    bool isComplete = false;
    uint256 immutable startBalance;
    uint256 immutable expiration = block.timestamp + 10 * 365 days;

    address immutable owner = msg.sender;
    address immutable beneficiary;

    constructor(address _player) payable {
        require(msg.value == 1 ether);
        require(_player != address(0), "Invalid address: zero address");

        beneficiary = _player;
        startBalance = msg.value;
    }

    function withdraw() external {
        require(msg.sender == owner);
        require(owner != address(0), "Invalid address: zero address");
        
        if (isComplete) revert();
        isComplete = true;


        if (block.timestamp < expiration) {
            // early withdrawal incurs a 10% penalty
            (bool response, ) = payable(msg.sender).call{ value: address(this).balance * 9 / 10 }("");
            if (response) {
                (bool beneficiaryResponse, ) = payable(beneficiary).call{ value: address(this).balance }("");
                if (!beneficiaryResponse) revert();
            } else {
                revert();
            }
        } else {
            (bool response, ) = payable(msg.sender).call{ value: address(this).balance }("");
            if (!response) revert();
        }
    }

    receive() external payable { }
}