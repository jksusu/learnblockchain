// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity >=0.7.0 <0.9.0;

import "./bank.sol";

contract BigBank is Bank {
    address owner;

    constructor() payable {
        owner = msg.sender;
    }

    modifier checkAmount(uint amount) {
        require(amount > 0.01 ether, "amount min 0.01 ether");
        _;
    }

    modifier checkOwner() {
        require(owner == msg.sender, "Insufficient permissions");
        _;
    }

    receive() external payable override checkAmount(msg.value) {
        emit Received(msg.sender, msg.value);
        balances[msg.sender] += msg.value;
        updateTopDepositors(msg.sender, msg.value);
    }

    function withdraw(uint amount, address withdrawAddress) public override {
        payable(withdrawAddress).transfer(amount);
    }

    //管理员可以修改下一任管理员
    function updateOnwer(address _owner) public checkOwner {
        owner = _owner;
    }

    function getOnwer() public view returns (address) {
        return owner;
    }
}
