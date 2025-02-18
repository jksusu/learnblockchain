// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface ITokenReceiver {
    function tokensReceived(address from, uint256 amount) external;
}
contract BaseERC20 {
    string public name = "BaseERC20"; 
    string public symbol = "BERC20"; 
    uint8 public decimals; 
    uint256 public totalSupply; 
    mapping (address => uint256) balances; 
    mapping (address => mapping (address => uint256)) allowances; 

    event Transfer(address indexed from, address indexed to, uint256 value);
    constructor() {
        decimals = 18;
        totalSupply = 100000000 * (10 ** uint256(decimals));
        balances[msg.sender] = totalSupply;
    }

    function transferWithCallback(address _to, uint256 _value) public returns (bool success) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        if (isContract(_to)) {
            ITokenReceiver(_to).tokensReceived(msg.sender, _value);
        }
        return true;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}