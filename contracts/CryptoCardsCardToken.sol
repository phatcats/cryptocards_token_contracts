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
    BIT-MAP:
                 T                 GM       I     S   C   R   G  Y
                140                32       32    12  8   16  8  8
[______________________________|________|________|___|__|____|__|__]



140 bits for
	- card traits, badges

32 bits for  (max 2,147,483,647)
	- Wrapped GUM amount

32 bits for  (max 2,147,483,647)
	- card issue

12 bits for  (max 4,096)
	- specialty/chase/sponsor cards  (not a crypto logo)
	- not combinable
	- extra gum?

8 bits for (max 256)
	- combined count (default 0)

16 bits for (max 65,536)
	- card rank

8 bits for  (max 256)
	- current generation

8 bits for (max 256)
	- year of issue ([20]19, [20]20, etc..)

*/

pragma solidity 0.5.0;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/access/roles/MinterRole.sol";
import "./CryptoCardsERC721Batched.sol";

contract OwnableDelegateProxy { }

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}

/**
 * @title Crypto-Cards ERC721 Card Token
 * ERC721-compliant token representing individual Cards
 */
contract CryptoCardsCardToken is CryptoCardsERC721Batched, MinterRole, Ownable {
    uint256 public constant START_YEAR = 2019;

    //
    // Storage
    //

    // Total Cards Issued by year => gen => rank
    mapping(uint => mapping(uint => mapping(uint => uint))) internal _totalIssued;

    // Tokens that have been printed
    mapping(uint => bool) internal _printedTokens;

    // The amount of GUM tokens earned by an address from melting or printing cards
    //  - to be paid out by claiming from the DAPP
    mapping(address => uint) internal _earnedGum;

    // The amount of ETH wrapped in a Token
    //  - paid immediately on melting or printing
    mapping(uint => uint) internal _wrappedEtherAmount;

    // During any given cycle, some random cards will have Wrapped ETH
    //  - this is the amount of ETH those random cards will each receive
    //  - can be changed with every cycle
    uint internal _wrappedEtherPerCard;

    // The amount of ETH wrapped in existing Tokens and not yet paid out
    //  - balance of contract must always be >= than this value
    uint internal _wrappedEtherDemand;

    // For registering token approvals through a proxy (OpenSea)
    address internal _proxyRegistryAddress;

    // GUM Token Controller
    address internal _cryptoCardsGum;

    //
    // Events
    //
    event CardsCombined(address indexed owner, uint256 tokenA, uint256 tokenB);
    event CardPrinted(address indexed owner, uint256 tokenId);
    event CardMelted(address indexed owner, uint256 tokenId, uint256 wrappedEther, uint256 wrappedGum);
    event WrappedEtherDeposit(uint256 amount);


    //
    // Modifiers
    //
    modifier onlyGumController() {
        require(msg.sender == _cryptoCardsGum, "Action only allowed by CryptoCardsGum contract");
        _;
    }

    //
    // Initialize
    //
    constructor() public CryptoCardsERC721Batched("Crypto-Cards - Cards", "CARDS", "https://crypto-cards.io/card-info/") { }

    //
    // Public
    //

    // Starts at 0, must add START_YEAR  (ie 0 + 2019)
    function getYear(uint256 tokenId) public pure returns (uint) {
        return uint(_readBits(tokenId, 0, 8));
    }

    // Starts at 0
    function getGeneration(uint256 tokenId) public pure returns (uint) {
        return uint(_readBits(tokenId, 8, 8));
    }

    // Starts at 0
    function getRank(uint256 tokenId) public pure returns (uint) {
        return uint(_readBits(tokenId, 16, 16));
    }

    function getTypeIndicators(uint256 tokenId) public pure returns (uint, uint, uint) {
        uint y = uint(_readBits(tokenId, 0, 8));
        uint g = uint(_readBits(tokenId, 8, 8));
        uint r = uint(_readBits(tokenId, 16, 16));
        return (y, g, r);
    }

    // Default 0
    function getCombinedCount(uint256 tokenId) public pure returns (uint) {
        return uint(_readBits(tokenId, 32, 8));
    }

    // Default 0
    function getSpecialty(uint256 tokenId) public pure returns (uint) {
        return uint(_readBits(tokenId, 40, 12));
    }

    // Starts at 1
    function getIssue(uint256 tokenId) public pure returns (uint) {
        return uint(_readBits(tokenId, 52, 32));
    }

    // Default 0
    function getWrappedGum(uint256 tokenId) public pure returns (uint) {
        return uint(_readBits(tokenId, 84, 32));
    }

    // Default 0
    function getTraits(uint256 tokenId) public pure returns (uint) {
        return uint(_readBits(tokenId, 116, 156));
    }

    function hasTrait(uint256 tokenId, uint256 trait) public pure returns (bool) {
        return getTraits(tokenId) & trait == trait;
    }

    function getTotalIssued(uint256 tokenId) public view returns (uint) {
        uint y = getYear(tokenId);
        uint g = getGeneration(tokenId);
        uint r = getRank(tokenId);
        return _totalIssued[y][g][r];
    }

    function isTokenPrinted(uint256 tokenId) public view returns (bool) {
        return _printedTokens[tokenId];
    }

    function canCombine(uint256 tokenA, uint256 tokenB) public view returns (bool) {
        if (isTokenPrinted(tokenA) || isTokenPrinted(tokenB)) { return false; }
        if (getGeneration(tokenA) < 1) { return false; }
        if (getSpecialty(tokenA) > 0) { return false; }

        uint32 typeA = uint32(_readBits(tokenA, 0, 32));
        uint32 typeB = uint32(_readBits(tokenB, 0, 32));
        return (typeA == typeB);
    }

    function combine(uint256 tokenA, uint256 tokenB) public returns (uint256) {
        require(msg.sender == ownerOf(tokenA), "You do not own one of these Cards"); // tokenB is verified via _combineTokens
        return _combineTokens(tokenA, tokenB);
    }

    function melt(uint256 tokenId) public {
        require(msg.sender == ownerOf(tokenId), "You do not own this Card");
        _meltToken(tokenId);
    }

    function getEarnedGum(address owner) public view returns (uint256) {
        return _earnedGum[owner];
    }

    function getWrappedEtherSupply() public view returns (uint256) {
        return address(this).balance; // must always be >= demand
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
    // Only Minter
    //

    function mintCardsFromPack(address to, uint256[] memory tokenIds) public onlyMinter {
        // Mint Tokens
        _mintBatch(to, tokenIds);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint t = tokenIds[i];
            (uint y, uint g, uint r) = getTypeIndicators(t);

            // Track Total Issued
            _totalIssued[y][g][r] = _totalIssued[y][g][r] + 1;

            // Attach Wrapped Ether (if any)
            if (hasTrait(t, 1)) {
                _wrappedEtherAmount[t] = _wrappedEtherPerCard;
                _wrappedEtherDemand = _wrappedEtherDemand.add(_wrappedEtherPerCard);
            }
        }
    }

    function printFor(address owner, uint256 tokenId) public onlyMinter {
        require(owner == ownerOf(tokenId), "User does not own this Card");
        _printToken(owner, tokenId);
    }

    function combineFor(address owner, uint256 tokenA, uint256 tokenB) public onlyMinter returns (uint256) {
        require(owner == ownerOf(tokenA), "User does not own this Card"); // tokenB is verified via _combineTokens
        return _combineTokens(tokenA, tokenB);
    }

    function meltFor(address owner, uint256 tokenId) public onlyMinter {
        require(owner == ownerOf(tokenId), "User does not own this Card");
        _meltToken(tokenId);
    }

    /* ???????????????????????????? */
    /* QUESTIONABLE for MINTER ROLE */
    function tokenTransfer(address from, address to, uint256 tokenId) public onlyMinter {
        _transferFrom(from, to, tokenId);
    }
    /* ???????????????????????????? */

    //
    // Only GUM Controller
    //

    function claimEarnedGum(address owner, uint256 amountClaimed) public onlyGumController {
        require(amountClaimed <= _earnedGum[owner], "Not enough GUM earned");
        _earnedGum[owner] = _earnedGum[owner].sub(amountClaimed);
    }

    //
    // Only Owner
    //

    function setGumController(address gumCtrl) public onlyOwner {
        require(gumCtrl != address(0), "Invalid address supplied");
        _cryptoCardsGum = gumCtrl;
    }

    function setBaseTokenURI(string memory uri) public onlyOwner {
        _baseTokenURI = uri;
    }

    function setProxyRegistryAddress(address proxy) public onlyOwner {
        _proxyRegistryAddress = proxy;
    }

    function setWrappedEtherAmount(uint256 amount) public onlyOwner {
        _wrappedEtherPerCard = amount;
    }

    function depositWrappedEther(uint256 amount) public payable onlyOwner {
        require(amount == msg.value, "Specified amount does not match actual amount received");
        emit WrappedEtherDeposit(amount);
    }

    function getWrappedEtherDemand() public view onlyOwner returns (uint256) {
        return _wrappedEtherDemand; // must always be <= supply
    }

    //
    // Private
    //

    function _combineTokens(uint256 tokenA, uint256 tokenB) private returns (uint256) {
        address owner = ownerOf(tokenA);  // will revert if owner == address(0)
        require(owner == ownerOf(tokenB), "User does not own both Cards");
        require(canCombine(tokenA, tokenB), "Cards are not compatible");

        // Mint New Token
        uint256 newTokenId = _generateCombinedToken(tokenA, tokenB);
        _mint(owner, newTokenId);

        // Combine Wrapped Ether
        _wrappedEtherAmount[newTokenId] = _wrappedEtherAmount[tokenA].add(_wrappedEtherAmount[tokenB]);
        _wrappedEtherAmount[tokenA] = 0;
        _wrappedEtherAmount[tokenB] = 0;

        // Burn Old Tokens
        _burn(owner, tokenA);
        _burn(owner, tokenB);

        // Emit Event
        emit CardsCombined(owner, tokenA, tokenB);

        return newTokenId;
    }

    function _printToken(address owner, uint256 tokenId) private {
        require(!isTokenPrinted(tokenId), "Card has already been printed");

        // Payout Wrapped Ether
        _payoutWrappedEther(tokenId);

        // GUM is Forfeit for Printed Cards

        // Mark as Printed
        _printedTokens[tokenId] = true;

        // Emit Event
        emit CardPrinted(owner, tokenId);
    }

    function _meltToken(uint256 tokenId) private {
        require(!isTokenPrinted(tokenId), "Cannot melt printed Cards");
        (address owner, uint wrappedEth) = _getWrappedEtherAmount(tokenId);

        // Burn Old Token
        _burn(owner, tokenId);

        // Transfer Wrapped Ether
        _payoutWrappedEther(tokenId, owner, wrappedEth);

        // Store amount of GUM earned from melting
        uint wrappedGum = getWrappedGum(tokenId);
        _earnedGum[owner] = _earnedGum[owner].add(wrappedGum);

        // Emit Event
        emit CardMelted(owner, tokenId, wrappedEth, wrappedGum);
    }

    function _getWrappedEtherAmount(uint256 tokenId) private view returns (address, uint256) {
        address owner = ownerOf(tokenId); // will revert if owner == address(0)
        uint wrappedEth = _wrappedEtherAmount[tokenId];
        // This should never happen, but just in case..
        require(wrappedEth <= address(this).balance, "Not enough funds to pay out wrapped ether, please try again later.");
        return (owner, wrappedEth);
    }

    function _payoutWrappedEther(uint256 tokenId) private {
        (address owner, uint wrappedEth) = _getWrappedEtherAmount(tokenId);
        _payoutWrappedEther(tokenId, owner, wrappedEth);
    }

    function _payoutWrappedEther(uint256 tokenId, address owner, uint wrappedEth) private {
        if (wrappedEth > 0) {
            address payable wallet = address(uint160(owner));
            _wrappedEtherAmount[tokenId] = 0;
            _wrappedEtherDemand = _wrappedEtherDemand.sub(wrappedEth);
            wallet.transfer(wrappedEth);
        }
    }

    function _generateTokenId(uint y, uint g, uint r, uint c, uint s, uint i, uint gm, uint t) private pure returns (uint256) {
        return uint256(y) | (uint256(g) << 8) | (uint256(r) << 16) | (uint256(c) << 32) | (uint256(s) << 40) | (uint256(i) << 52) | (uint256(gm) << 84) | (uint256(t) << 116);
    }

    function _generateCombinedToken(uint256 tokenA, uint256 tokenB) private returns (uint256) {
        uint y = getYear(tokenA);
        uint g = getGeneration(tokenA).sub(1);
        uint r = getRank(tokenA);
        uint cA = getCombinedCount(tokenA);
        uint cB = getCombinedCount(tokenB);
        uint i = _totalIssued[y][g][r].add(1);
        uint gm = getWrappedGum(tokenA).add(getWrappedGum(tokenB));
        uint t = getTraits(tokenA) | getTraits(tokenB);

        _totalIssued[y][g][r] = i; // Update Max-Issue for New Token Generation

        return _generateTokenId(y, g, r, ((cA > cB ? cB : cA) + 1), 0, i, gm, t);
    }

    function _traitByIndex(uint256 index) private pure returns (uint256) {
        return uint256(1 << index);
    }

    function _readBits(uint num, uint from, uint len) private pure returns (uint) {
        uint mask = ((1 << len) - 1) << from;
        return (num & mask) >> from;
    }
}
