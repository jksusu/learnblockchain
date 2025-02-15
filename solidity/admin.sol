pragma solidity <0.9.0;

interface IBank {
    function withdraw(uint, address) external;

    function getBalance() external view returns (uint);
}

contract Admin {
    address owner;

    event Received(uint amount, address from);

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        emit Received(msg.value, msg.sender);
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    function adminWithdraw(IBank bank) public {
        bank.withdraw(bank.getBalance(), owner);
    }
}
