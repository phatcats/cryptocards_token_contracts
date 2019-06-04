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

import "./ERC721Enumerable.sol";

contract IERC721BatchReceiver {
    function onERC721BatchReceived(address operator, address from, uint256[] memory tokenIds, bytes memory data)
    public returns (bytes4);
}

contract OwnableDelegateProxy { }

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

/**
 * @title Crypto-Cards ERC721-Batched Tokens
 */
contract CryptoCardsERC721Batched is ERC721Enumerable {

    //
    // Storage
    //
    string internal _tokenName;
    string internal _tokenSymbol;
    string internal _baseTokenURI;

    // For registering token approvals through a proxy (OpenSea)
    address internal _proxyRegistryAddress;

    bytes4 private constant _INTERFACE_ID_ERC721_BATCH = 0xd81081bb;
    /*
     * 0xd81081bb ===
     *     bytes4(keccak256('batchTransferFrom(address,address,uint256[])')) ^
     *     bytes4(keccak256('safeBatchTransferFrom(address,address,uint256[])')) ^
     *     bytes4(keccak256('safeBatchTransferFrom(address,address,uint256[],bytes)'))
     */

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;
    /**
     * 0x5b5e139f ===
     *     bytes4(keccak256('name()')) ^
     *     bytes4(keccak256('symbol()')) ^
     *     bytes4(keccak256('tokenURI(uint256)'))
     */

    bytes4 private constant _ERC721_BATCH_RECEIVED = 0x4b808c46;
    /**
     * 0x4b808c46 ===
     *     bytes4(keccak256("onERC721BatchReceived(address,address,uint256[],bytes)"))
     */

    //
    // Events
    //
    event BatchTransfer(address from, address to, uint256[] tokenIds);

    //
    // Initialize
    //
    constructor(string memory name, string memory symbol, string memory uri) public {
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
        _registerInterface(_INTERFACE_ID_ERC721_BATCH);

        _tokenName = name;
        _tokenSymbol = symbol;
        _baseTokenURI = uri;
    }

    //
    // Public
    //

    function name() external view returns (string memory) {
        return _tokenName;
    }

    function symbol() external view returns (string memory) {
        return _tokenSymbol;
    }

    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Token doesn't exist");
        return string(abi.encodePacked(
                _baseTokenURI,
                uint2str(tokenId),
                ".json"
            ));
    }

    function exists(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    function safeBatchTransferFrom(address from, address to, uint256[] memory tokenIds) public {
        safeBatchTransferFrom(from, to, tokenIds, "");
    }

    function safeBatchTransferFrom(address from, address to, uint256[] memory tokenIds, bytes memory _data) public {
        batchTransferFrom(from, to, tokenIds);
        require(_checkOnERC721BatchReceived(from, to, tokenIds, _data));
    }

    function batchTransferFrom(address from, address to, uint256[] memory tokenIds) public {
        require(to != address(0));

        for (uint256 i = 0; i < tokenIds.length; i++) {
            _fastTransferFrom(from, to, tokenIds[i]);
        }

        _ownedTokensCount[from] = _ownedTokensCount[from].sub(tokenIds.length);
        _ownedTokensCount[to] = _ownedTokensCount[to].add(tokenIds.length);

        emit BatchTransfer(from, to, tokenIds);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        // Whitelist OpenSea proxy contract for easy trading.
        ProxyRegistry proxyRegistry = ProxyRegistry(_proxyRegistryAddress);
        if (address(proxyRegistry.proxies(owner)) == operator) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

    //
    // Private
    //

    function _setProxyRegistryAddress(address proxy) internal {
        _proxyRegistryAddress = proxy;
    }

    function _mintBatch(address to, uint256[] memory tokenIds) internal {
        require(to != address(0));

        for (uint256 i = 0; i < tokenIds.length; i++) {
            _fastMint(to, tokenIds[i]);
        }

        _ownedTokensCount[to] = _ownedTokensCount[to].add(tokenIds.length);

        emit BatchTransfer(address(0x0), to, tokenIds);
    }

    function _checkOnERC721BatchReceived(address from, address to, uint256[] memory tokenIds, bytes memory _data) internal returns (bool) {
        if (!to.isContract()) { return true; }

        bytes4 retval = IERC721BatchReceiver(to).onERC721BatchReceived(msg.sender, from, tokenIds, _data);
        return (retval == _ERC721_BATCH_RECEIVED);
    }

    function uint2str(uint _i) private pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }

        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }

        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }

        return string(bstr);
    }
}