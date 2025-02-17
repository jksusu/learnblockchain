pragma solidity ^0.8.0;

import "./tokenBank.sol";

contract TokenBankV2 is TokenBank {
    mapping(address => uint256) public balances;

    function transferWithCallback(address from, uint256 amount) external {
        require(msg.sender == address(this), "Only TokenBankV2 can call this");
        balances[from] += amount;
    }
}
