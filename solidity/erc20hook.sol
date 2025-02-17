pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface ITokenReceiver {
    function tokensReceived(address from, uint256 amount) external;
}

contract ExtendedERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function transferWithCallback(address to, uint256 amount) public returns (bool) {
        _transfer(msg.sender, to, amount);
        if (isContract(to)) {
            ITokenReceiver(to).tokensReceived(msg.sender, amount);
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
