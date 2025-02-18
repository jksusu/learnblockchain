pragma solidity ^0.8.0;

import {IERC20} "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenBank {
    IERC20 public token;
    mapping(address => uint256) public balances;

    modifier checkAmount(uint amount) {
        require(amount > 0, "Amount must be greater than 0");
        _;
    }

    constructor(IERC20 _token) {
        token = _token;
    }

    function deposit(uint256 amount) external checkAmount(amount){
        token.transferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
    }

    function withdraw(uint256 amount) external checkAmount(amount) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        token.transfer(msg.sender, amount);
    }

    function tokensReceived(address from,uint256 amount) external returns (bool) {
        require(address(token) == msg.sender, "Only tokens allowed"); 
        balances[address(token)] += amount;
        emit TokensReceived(from, amount);
        return true;
    }
}