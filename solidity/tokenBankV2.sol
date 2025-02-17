pragma solidity ^0.8.0;

import "./tokenBank.sol";
import "./erc20Hook.sol";

contract TokenBankV2 is TokenBank {
    constructor(ExtendedERC20 _token) TokenBank(_token) {}

    function depositWithCallback(uint256 amount) external checkAmount(amount) {
        ExtendedERC20(address(token)).transferWithCallback(address(this), amount);
        balances[msg.sender] += amount;
    }
}