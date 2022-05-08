// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "ds-stop/stop.sol";
import "zeppelin-solidity/utils/Strings.sol";
import "zeppelin-solidity/token/ERC1155/ERC1155.sol";
import "zeppelin-solidity/token/ERC1155/extensions/ERC1155Burnable.sol";
import "zeppelin-solidity/token/ERC1155/extensions/ERC1155Supply.sol";

contract Ticket is DSStop, ERC1155(""), ERC1155Burnable, ERC1155Supply {
    using Strings for uint256;

    mapping(uint256 => bytes32) private metadataHash;

    function setMedadataHash(uint256 id, bytes32 hash) public auth {
        metadataHash[id] = hash;
    }

    function setURI(string memory newuri) public auth {
        _setURI(newuri);
    }

    function uri(uint256 id) public view override returns (string memory) {
        return toFullURI(metadataHash[id], id);
    }

    function toFullURI(bytes32 hash, uint256 id) public pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "ipfs://",
                    hash2base32(hash),
                    "/",
                    id.toString(),
                    ".json"
                )
            );
    }

    bytes32 private constant base32Alphabet = 0x6162636465666768696A6B6C6D6E6F707172737475767778797A323334353637;

    function hash2base32(bytes32 _hash)
        private
        pure
        returns (string memory _uintAsString)
    {
        uint256 _i = uint256(_hash);
        uint256 k = 52;
        bytes memory bstr = new bytes(k);
        bstr[--k] = base32Alphabet[uint8((_i % 8) << 2)];
        _i /= 8;
        while (k > 0) {
            bstr[--k] = base32Alphabet[_i % 32];
            _i /= 32;
        }
        return string(bstr);
    }

    function create(address account, uint256 id, uint256 amount) public auth {
        _mint(account, id, amount, "");
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        auth
    {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        auth
    {
        _mintBatch(to, ids, amounts, data);
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        stoppable
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
