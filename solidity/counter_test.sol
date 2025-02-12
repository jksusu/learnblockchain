// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Counter {
    int private counter;

    function getCounter() public view returns (int) {
        return counter;
    }

    function add(int x) public {
        counter += x;
    }
}