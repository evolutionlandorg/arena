// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Arena {
    // constructor(address bootstrapper) public {
    //     BootstrapFeature bootstrap = new BootstrapFeature(bootstrapper);
    //     LibProxyStorage.getStorage().impls[bootstrap.bootstrap.selector] =
    //         address(bootstrap);
    // }

    // fallback() external payable {
    //     mapping(bytes4 => address) storage impls =
    //         LibProxyStorage.getStorage().impls;

    //     assembly {
    //         let cdlen := calldatasize()

    //         if iszero(cdlen) {
    //             return(0, 0)
    //         }

    //         calldatacopy(0x40, 0, cdlen)
    //         let selector := and(mload(0x40), 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)

    //         mstore(0, selector)
    //         mstore(0x20, impls_slot)
    //         let slot := keccak256(0, 0x40)

    //         let delegate := sload(slot)
    //         if iszero(delegate) {
    //             // Revert with:
    //             // abi.encodeWithSelector(
    //             //   bytes4(keccak256("NotImplementedError(bytes4)")),
    //             //   selector)
    //             mstore(0, 0x734e6e1c00000000000000000000000000000000000000000000000000000000)
    //             mstore(4, selector)
    //             revert(0, 0x24)
    //         }

    //         let success := delegatecall(
    //             gas(),
    //             delegate,
    //             0x40, cdlen,
    //             0, 0
    //         )
    //         let rdlen := returndatasize()
    //         returndatacopy(0, 0, rdlen)
    //         if success {
    //             return(0, rdlen)
    //         }
    //         revert(0, rdlen)
    //     }
    // }
}
