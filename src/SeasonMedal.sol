// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "zeppelin-solidity/access/Ownable.sol";
import "zeppelin-solidity/utils/Counters.sol";
import "zeppelin-solidity/security/Pausable.sol";
import "zeppelin-solidity/token/ERC721/ERC721.sol";
import "zeppelin-solidity/token/ERC721/extensions/ERC721Burnable.sol";
import "zeppelin-solidity/token/ERC721/extensions/ERC721Enumerable.sol";
import "zeppelin-solidity/token/ERC721/extensions/ERC721URIStorage.sol";

contract SeasonMedal is ERC721, ERC721Enumerable, ERC721URIStorage, Pausable, Ownable, ERC721Burnable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    string public baseURI;

    constructor() ERC721("Arena Season Medal", "MEDAL") {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint(address to, string memory uri) public onlyOwner {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory newbaseURI) public onlyOwner {
        baseURI = newbaseURI;
    }

    function setTokenURI(uint256 tokenId, string memory uri) public onlyOwner {
        _setTokenURI(tokenId, uri);
    }

    function batchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids
    ) external {
        for (uint256 i = 0; i < ids.length; ++i) {
            transferFrom(from, to, ids[i]);
        }
    }
}
