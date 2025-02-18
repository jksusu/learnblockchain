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
    event Approval(address indexed owner, address indexed spender, uint256 value);

    //检测某个地址的余额是否足够
    modifier checkBalances(address _address, uint amount) {
        require(balances[_address] >= amount, "ERC20: transfer amount exceeds balance");
        _;
    }

    constructor() {
        decimals = 18;
        totalSupply = 100000000 * (10 ** uint256(decimals));
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public checkBalances(msg.sender, _value)  returns (bool success) {
        //判断余额是否足够
        balances[msg.sender] = balances[msg.sender] - _value; 
        balances[_to] = balances[_to] + _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        //检查是否存在权限
        uint amount = allowances[_from][msg.sender];
        require(amount >= _value, "ERC20: transfer amount exceeds allowance");
        require(balances[_from] >= _value, "ERC20: transfer amount exceeds balance");

        balances[_from] -= _value; 
        balances[_to] += _value;

        allowances[_from][msg.sender] -= _value; // 更新被授权者的额度

        emit Transfer(_from, _to, _value); 
        return true; 
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value); 
        return true; 
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {   
        // write your code here   
        return allowances[_owner][_spender];  
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

    function transferWithCall(address _to, uint256 _value) public returns (bool success) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        if (isContract(_to)) {
            ITokenReceiver(_to).tokensReceived(msg.sender, _value);
        }
        return true;
    }
}