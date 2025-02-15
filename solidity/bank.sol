pragma solidity <0.9.0;

import "./admin.sol";

contract Bank is IBank {
    mapping(address => uint) balances;
    uint256[3] private topAmounts;
    address[3] private topDepositors;

    address private owner;

    constructor() {
        owner = msg.sender;
    }

    event Received(address sender, uint amount);

    receive() external payable virtual {
        emit Received(msg.sender, msg.value);
        balances[msg.sender] += msg.value;
        updateTopDepositors(msg.sender, msg.value);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function updateTopDepositors(address user, uint256 amount) internal {
        for (uint256 i = 0; i < 3; i++) {
            if (amount > topAmounts[i]) {
                // 移动后面的用户
                for (uint256 j = 2; j > i; j--) {
                    topDepositors[j] = topDepositors[j - 1];
                    topAmounts[j] = topAmounts[j - 1];
                }
                // 更新当前用户
                topDepositors[i] = user;
                topAmounts[i] = amount;
                break;
            }
        }
    }

    function getTopDepositors()
        public
        view
        returns (address[3] memory, uint256[3] memory)
    {
        return (topDepositors, topAmounts);
    }

    function withdraw(
        uint amount,
        address withdrawAddress
    ) public virtual override {
        require(msg.sender == owner, "Insufficient permissions"); //管理员可以转账出去
        payable(withdrawAddress).transfer(amount); // 转账到指定地址
    }
}
