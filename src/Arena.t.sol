// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "ds-test/test.sol";

import "./Arena.sol";

contract ArenaTest is DSTest {
    Arena arena;

    function setUp() public {
        arena = new Arena();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
