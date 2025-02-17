pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Hook is ERC20 {
    function transferWithCallback(
        address recipient,
        uint256 amount
    ) public returns (bool) {
        super.transfer(recipient, amount);
        if (isContract(recipient)) {
            ITokenReceiver(recipient).tokensReceived(msg.sender, amount);
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

interface ITokenReceiver {
    function tokensReceived(address from, uint256 amount) external;
}