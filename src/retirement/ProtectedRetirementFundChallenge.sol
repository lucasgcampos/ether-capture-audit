// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract ProtectedRetirementFundChallenge {
    
    bool isComplete = false;
    uint256 immutable EXPIRATION = block.timestamp + 10 * 365 days;

    address immutable OWNER = msg.sender;
    address immutable BENEFICIARY;

    constructor(address _player) payable {
        require(msg.value == 1 ether);
        require(_player != address(0), "Invalid address: zero address");

        BENEFICIARY = _player;
    }

    function withdraw() external {
        require(msg.sender == OWNER);
        require(OWNER != address(0), "Invalid address: zero address");
        
        if (isComplete) revert();
        isComplete = true;


        if (block.timestamp < EXPIRATION) {
            // early withdrawal incurs a 10% penalty
            (bool response, ) = payable(msg.sender).call{ value: address(this).balance * 9 / 10 }("");
            if (response) {
                (bool beneficiaryResponse, ) = payable(BENEFICIARY).call{ value: address(this).balance }("");
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