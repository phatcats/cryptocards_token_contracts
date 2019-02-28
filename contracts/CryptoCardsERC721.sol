/**
 * Phat Cats - Crypto-Cards
 *  - https://crypto-cards.io
 *  - https://phatcats.co
 *
 * Copyright 2019 (c) Phat Cats, Inc.
 *
 * Contract Audits:
 *   - SmartDEC International - https://smartcontracts.smartdec.net
 *   - Callisto Security Department - https://callisto.network/
 */

pragma solidity 0.5.0;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol";
import "openzeppelin-solidity/contracts/token/ERC721/ERC721MetadataMintable.sol";


contract OwnableDelegateProxy { }

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

/**
 * @title Crypto-Cards ERC721 Token
 */
contract CryptoCardsERC721 is Ownable, ERC721Full, ERC721MetadataMintable {
    address internal proxyRegistryAddress;
    mapping(uint256 => bool) internal tokenFrozenById; // Applies to Opened Packs and Printed Cards

    constructor(string memory name, string memory symbol) public ERC721Full(name, symbol) { }

    function setProxyRegistryAddress(address _proxyRegistryAddress) public onlyOwner {
        proxyRegistryAddress = _proxyRegistryAddress;
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        // Whitelist OpenSea proxy contract for easy trading.
        ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

    function isTokenFrozen(uint256 _tokenId) public view returns (bool) {
        return tokenFrozenById[_tokenId];
    }

    function freezeToken(uint256 _tokenId) public onlyMinter {
        tokenFrozenById[_tokenId] = true;
    }

    function tokenTransfer(address _from, address _to, uint256 _tokenId) public onlyMinter {
        _transferFrom(_from, _to, _tokenId);
    }

    function _transferFrom(address _from, address _to, uint256 _tokenId) internal {
        require(tokenFrozenById[_tokenId] != true);
        super._transferFrom(_from, _to, _tokenId);
    }
}
