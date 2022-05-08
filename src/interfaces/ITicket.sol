// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface ITicket {
    function create(address account, uint256 id, uint256 amount) external returns (uint256);
}
