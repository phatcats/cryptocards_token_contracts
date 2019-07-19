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
/*

NOTES:
    - Contract holds ETH for distribution from Card Melting & Printing
    - Token IDs are bit-mapped to store:
        - Card Year
        - Card Generation
        - Card Rank
        - Card Issue
        - Wrapped GUM
        - Wrapped ETH

TOKEN-ID BIT-MAP:
      E       G    I   R   G  Y
      22      10   12  10  6  4
[____________|___|____|___|__|_]


22 bits for (max 4,194,304)
	- wrapped ether (divided by 1,000,000)
         4194304 / 1000000 = 4.194304
		   10000 / 1000000 = 0.01
		       1 / 1000000 = 0.000001

10 bits for  (max 1,024)
	- wrapped gum

12 bits for  (max 4,096)
	- card issue

10 bits for  (max 1,024)
	- card rank

6 bits for  (max 64)
	- current generation

4 bits for (max 16)
	- year of issue (0 = 2019)

*/

pragma solidity 0.5.0;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/access/roles/MinterRole.sol";
import "./CryptoCardsERC721Batched.sol";

/**
 * @title Crypto-Cards ERC721 Card Token
 * ERC721-compliant token representing individual Cards
 */
contract CryptoCardsCardToken is CryptoCardsERC721Batched, MinterRole, Ownable {
    uint internal constant ETH_DIV = 1000000;
    uint internal constant ETH_MAX = 4194304;

    //
    // Storage
    //
    // Total Cards Issued by year => gen => rank
    mapping(uint64 => mapping(uint64 => mapping(uint64 => uint64))) internal _totalIssued;

    // Tokens that have been printed
    mapping(uint => bool) internal _printedTokens;

    // The amount of ETH wrapped in existing Tokens and not yet paid out
    //  - balance of contract must always be >= than this value
    uint internal _wrappedEtherDemand;

    //
    // Events
    //
    event CardsCombined(address indexed owner, uint tokenA, uint tokenB, uint newTokenId);
    event CardPrinted(address indexed owner, uint tokenId, uint wrappedEther, uint wrappedGum);
    event CardMelted(address indexed owner, uint tokenId, uint wrappedEther, uint wrappedGum);
    event WrappedEtherDeposit(uint amount);

    //
    // Initialize
    //
    constructor() public CryptoCardsERC721Batched("Crypto-Cards - Cards", "CARDS", "https://crypto-cards.io/card-info/") { }

    //
    // Public
    //

    // Starts at 0, must add START_YEAR  (ie 0 + 2019)
    function getYear(uint tokenId) public pure returns (uint64) {
        return _readBits(tokenId, 0, 4);
    }

    // Starts at 0
    function getGeneration(uint tokenId) public pure returns (uint64) {
        return _readBits(tokenId, 4, 6);
    }

    // Starts at 0
    function getRank(uint tokenId) public pure returns (uint64) {
        return _readBits(tokenId, 10, 10);
    }

    // Starts at 1
    function getIssue(uint tokenId) public pure returns (uint64) {
        return _readBits(tokenId, 20, 12);
    }

    function getTypeIndicators(uint tokenId) public pure returns (uint64, uint64, uint64) {
        uint64 y = getYear(tokenId);
        uint64 g = getGeneration(tokenId);
        uint64 r = getRank(tokenId);
        return (y, g, r);
    }

    // Default 0
    function getWrappedGum(uint tokenId) public pure returns (uint64) {
        return _readBits(tokenId, 32, 10);
    }

    // Default 0
    function getWrappedEther(uint tokenId) public pure returns (uint) {
        return _convertToEther(_getWrappedEtherRaw(tokenId));
    }

    function getTotalIssued(uint tokenId) public view returns (uint64) {
        (uint64 y, uint64 g, uint64 r) = getTypeIndicators(tokenId);
        return _totalIssued[y][g][r];
    }

    function isTokenPrinted(uint tokenId) public view returns (bool) {
        return _printedTokens[tokenId];
    }

    function canCombine(uint tokenA, uint tokenB) public view returns (bool) {
        if (isTokenPrinted(tokenA) || isTokenPrinted(tokenB)) { return false; }
        if (getGeneration(tokenA) < 1) { return false; }

        uint32 typeA = uint32(_readBits(tokenA, 0, 20)); // y, g, r
        uint32 typeB = uint32(_readBits(tokenB, 0, 20)); // y, g, r
        return (typeA == typeB);
    }

//    function getWrappedEtherSupply() public view returns (uint) {
//        return address(this).balance; // must always be >= demand
//    }

    //
    // Only Minter
    //

    function mintCardsFromPack(address to, uint[] memory tokenIds) public onlyMinter {
        // Mint Tokens
        _mintBatch(to, tokenIds);

        uint totalWrappedEth;
        for (uint i = 0; i < tokenIds.length; i++) {
            uint t = tokenIds[i];
            (uint64 y, uint64 g, uint64 r) = getTypeIndicators(t);

            // Track Total Issued
            _totalIssued[y][g][r] = _totalIssued[y][g][r] + 1;

            // Track Wrapped Ether (if any)
            totalWrappedEth = totalWrappedEth + getWrappedEther(t);
        }
        if (totalWrappedEth > 0) {
            _wrappedEtherDemand = _wrappedEtherDemand + totalWrappedEth;
        }
    }

    function mintCard(address to, uint tokenId) public onlyMinter {
        // Mint Tokens
        _mint(to, tokenId);

        uint wrappedEth;
        (uint64 y, uint64 g, uint64 r) = getTypeIndicators(tokenId);

        // Track Total Issued
        _totalIssued[y][g][r] = _totalIssued[y][g][r] + 1;

        // Track Wrapped Ether (if any)
        wrappedEth = wrappedEth + getWrappedEther(tokenId);
        _wrappedEtherDemand = _wrappedEtherDemand + wrappedEth;
    }

    function printFor(address owner, uint tokenId) public onlyMinter returns (uint) {
        require(owner == ownerOf(tokenId), "User does not own this Card");
        return _printToken(owner, tokenId);
    }

    function combineFor(address owner, uint tokenA, uint tokenB) public onlyMinter returns (uint) {
        require(owner == ownerOf(tokenA), "User does not own this Card"); // tokenB is verified via _combineTokens
        return _combineTokens(tokenA, tokenB);
    }

    function meltFor(address owner, uint tokenId) public onlyMinter returns (uint) {
        require(owner == ownerOf(tokenId), "User does not own this Card");
        return _meltToken(tokenId);
    }

    /* ???????????????????????????? */
    /* QUESTIONABLE for MINTER ROLE */
//    function tokenTransfer(address from, address to, uint tokenId) public onlyMinter {
//        _transferFrom(from, to, tokenId);
//    }
    /* ???????????????????????????? */

    //
    // Only Owner
    //

    function setBaseTokenURI(string memory uri) public onlyOwner {
        _baseTokenURI = uri;
    }

    function setProxyRegistryAddress(address proxy) public onlyOwner {
        _setProxyRegistryAddress(proxy);
    }

    function depositWrappedEther(uint amount) public payable onlyOwner {
        require(amount == msg.value, "Specified amount does not match actual amount received");
        emit WrappedEtherDeposit(amount);
    }

    function getWrappedEtherDemand() public view onlyOwner returns (uint) {
        return _wrappedEtherDemand; // must always be <= supply
    }

    //
    // Private
    //

    function _combineTokens(uint tokenA, uint tokenB) private returns (uint) {
        address owner = ownerOf(tokenA);  // will revert if owner == address(0)
        require(owner == ownerOf(tokenB), "User does not own both Cards");
        require(canCombine(tokenA, tokenB), "Cards are not compatible");

        uint newTokenId = _generateCombinedToken(tokenA, tokenB);
        _mint(owner, newTokenId);

        _burn(owner, tokenA);
        _burn(owner, tokenB);

        emit CardsCombined(owner, tokenA, tokenB, newTokenId);
        return newTokenId;
    }

    function _printToken(address owner, uint tokenId) private returns (uint) {
        require(!isTokenPrinted(tokenId), "Card has already been printed");

        uint wrappedGum = getWrappedGum(tokenId);
        uint wrappedEth = getWrappedEther(tokenId);

        _printedTokens[tokenId] = true;
        _payoutEther(owner, wrappedEth);

        emit CardPrinted(owner, tokenId, wrappedEth, wrappedGum);
        return wrappedGum;
    }

    function _meltToken(uint tokenId) private returns (uint) {
        require(!isTokenPrinted(tokenId), "Cannot melt printed Cards");
        address owner = ownerOf(tokenId);

        uint wrappedGum = getWrappedGum(tokenId);
        uint wrappedEth = getWrappedEther(tokenId);

        _burn(owner, tokenId);
        _payoutEther(owner, wrappedEth);

        emit CardMelted(owner, tokenId, wrappedEth, wrappedGum);
        return wrappedGum;
    }

    function _payoutEther(address owner, uint256 ethAmount) private returns (uint) {
        address payable ownerWallet = address(uint160(owner));

        // This should never happen, but just in case..
        require(ethAmount <= address(this).balance, "Not enough funds to pay out wrapped ether, please try again later.");

        _wrappedEtherDemand = _wrappedEtherDemand - ethAmount;

        ownerWallet.transfer(ethAmount);
        return ethAmount;
    }

    function _generateCombinedToken(uint tokenA, uint tokenB) private returns (uint) {
        uint64 y = getYear(tokenA);
        uint64 g = getGeneration(tokenA) - 1;
        uint64 r = getRank(tokenA);
        uint64 i = _totalIssued[y][g][r] + 1;
        uint64 eth = _getCombinedEtherRaw(tokenA, tokenB);

        _totalIssued[y][g][r] = i; // Update Max-Issue for New Token Generation

        uint64[6] memory bits = [
            y, g, r, i,
            getWrappedGum(tokenA) + getWrappedGum(tokenB),
            eth
        ];
        return _generateTokenId(bits);
    }

    function _getCombinedEtherRaw(uint tokenA, uint tokenB) private returns (uint64) {
        uint64 eA = _getWrappedEtherRaw(tokenA);
        uint64 eB = _getWrappedEtherRaw(tokenB);
        uint combined = uint(eA + eB);

        // Check wrapped ether
        if (combined > ETH_MAX) { // MAX Wrapped Ether
            uint overage = _convertToEther(combined - ETH_MAX);
            _payoutEther(ownerOf(tokenA), overage);
            combined = ETH_MAX;
        }
        return uint64(combined);
    }

    // Default 0
    function _getWrappedEtherRaw(uint tokenId) private pure returns (uint64) {
        return _readBits(tokenId, 42, 22);
    }

    function _convertToEther(uint rawValue) private pure returns (uint) {
        return rawValue * (1 ether) / ETH_DIV;
    }

    function _generateTokenId(uint64[6] memory bits) private pure returns (uint) {
        return uint(bits[0] | (bits[1] << 4) | (bits[2] << 10) | (bits[3] << 20) | (bits[4] << 32) | (bits[5] << 42));
    }

    function _readBits(uint num, uint from, uint len) private pure returns (uint64) {
        uint mask = ((1 << len) - 1) << from;
        return uint64((num & mask) >> from);
    }
}
