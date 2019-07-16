/**
 * Phat Cats - Crypto-Cards
 *  - https://crypto-cards.io
 *  - https://phatcats.co
 *
 * Copyright 2019 (c) Phat Cats, Inc.
 *
 * Contract Audits:
 *   - Callisto Security Department - https://callisto.network/
 */

pragma solidity 0.5.0;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/access/roles/MinterRole.sol";
import "./CryptoCardsERC721Batched.sol";

/**
 * @title Crypto-Cards ERC721 Pack Token
 * ERC721-compliant token representing individual Packs
 */
contract CryptoCardsPackToken is CryptoCardsERC721Batched, MinterRole, Ownable {

    //
    // Storage
    //
    mapping(uint256 => string) internal _packData;

    //
    // Initialize
    //
    constructor() public CryptoCardsERC721Batched("Crypto-Cards Packs", "PACKS", "https://crypto-cards.io/pack-info/") { }

    //
    // Public
    //

    function packDataById(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Invalid tokenId supplied");
        return _packData[tokenId];
    }

    //
    // Only Minter
    //

    function mintPack(address to, string memory packData) public onlyMinter returns (uint256) {
        uint256 tokenId = totalSupply();
        _mint(to, tokenId);
        _packData[tokenId] = packData;
        return tokenId;
    }

//    function mintPacks(address to, uint256[] memory tokenIds) public onlyMinter {
//        _mintBatch(to, tokenIds);
//    }

    function burnPack(address from, uint256 tokenId) public onlyMinter {
        _burn(from, tokenId);
        _packData[tokenId] = "";
    }

//    function tokenTransfer(address from, address to, uint256 tokenId) public onlyMinter {
//        _transferFrom(from, to, tokenId);
//    }

    //
    // Only Owner
    //

    function setProxyRegistryAddress(address proxy) public onlyOwner {
        _setProxyRegistryAddress(proxy);
    }
}
