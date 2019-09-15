/**
 * Phat Cats - Crypto-Cards
 *  - https://crypto-cards.io
 *  - https://phatcats.co
 *
 * Copyright 2019 (c) Phat Cats, Inc.
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
    uint256 internal _totalMintedPacks;
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

    function totalMintedPacks() public view returns (uint256) {
        return _totalMintedPacks;
    }

    //
    // Only Minter
    //   Note: Minter is the Pack-Controller Contract, which is the only Minter ever assigned.
    //         Only the Minter can add new minters, and as the Pack-Controller Contract has no code for
    //         assigning new Minters, no new minters can ever be added.
    //

    function mintPack(address to, string memory packData) public onlyMinter returns (uint256) {
        _totalMintedPacks = _totalMintedPacks + 1;
        uint256 tokenId = _totalMintedPacks;
        _mint(to, tokenId);
        _packData[tokenId] = packData;
        return tokenId;
    }

    function burnPack(address from, uint256 tokenId) public onlyMinter {
        _burn(from, tokenId);
        _packData[tokenId] = "";
    }

    function tokenTransfer(address from, address to, uint256 tokenId) public onlyMinter {
        _transferFrom(from, to, tokenId);
    }

    //
    // Only Owner
    //

    function setProxyRegistryAddress(address proxy) public onlyOwner {
        _setProxyRegistryAddress(proxy);
    }
}
