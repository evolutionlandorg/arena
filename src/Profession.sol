// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "ds-stop/stop.sol";
import "zeppelin-solidity/token/ERC20/IERC20.sol";
import "zeppelin-solidity/token/ERC20/utils/SafeERC20.sol";

contract Profession is DSStop {
    using SafeERC20 for IERC20;

    event Buy(address indexed user, uint256 indexed amount);

    address public immutable USDT;
    address public immutable DEV_POOL;

    uint256 public fee = 5e6;

    constructor(address usdt, address dev_pool) {
        USDT = usdt;
        DEV_POOL = dev_pool;
    }

    /// @dev Change profession for universal nft
    /// @param land The landid which the nft located
    /// @param nft The nft token address
    /// @param id The token id of nft
    /// @param extra Extra data which could custom by backend
    function buyProfessionTicket(uint256 amount) external stoppable {
        address user = msg.sender;
        IERC20(USDT).safeTransferFrom(user, DEV_POOL, fee * amount);
        emit Buy(user, amount);
    }

    function setFee(uint256 _fee) external auth {
        fee = _fee;
    }
}
