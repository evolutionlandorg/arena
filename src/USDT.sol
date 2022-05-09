// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "zeppelin-solidity/access/Ownable.sol";
import "zeppelin-solidity/token/ERC20/ERC20.sol";
import "zeppelin-solidity/token/ERC20/extensions/ERC20Burnable.sol";

contract USDT is ERC20, ERC20Burnable, Ownable {
    constructor() ERC20("Tether USD", "USDT") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function decimals() public pure override returns (uint8) {
        return 6;
    }
}
