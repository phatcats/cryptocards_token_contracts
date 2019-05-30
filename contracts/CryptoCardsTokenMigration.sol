
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

import "./strings.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";

import "./CryptoCardsCardToken.sol";
import "./CryptoCardsPackToken.sol";
import "./CryptoCardsGumToken.sol";


contract CryptoCardsCards {
    function cardHashById(uint256 cardId) public view returns (string memory);
}

contract CryptoCardsPacks {
    function packDataById(uint256 cardId) public view returns (string memory);
}


/**
 * @title Crypto-Cards Token Migration
 *  - converts ERC20 and ERC721 tokens to ERC1155
 *  - must add this contract as a minter for all token contracts
 */
contract CryptoCardsTokenMigration is Ownable {
    using strings for *;

    CryptoCardsCardToken internal _cardToken;
    CryptoCardsPackToken internal _packToken;
    CryptoCardsGumToken internal _gumToken;
    CryptoCardsCards internal _cryptoCardsCards;
    CryptoCardsPacks internal _cryptoCardsPacks;

    // [0] = In-House               (Sent to In-House Account)
    // [1] = Bounty Rewards         (Sent to Bounty-Rewards Account)
    // [2] = Marketing Rewards      (Sent to Marketing Rewards Account)
    // [3] = Exchanges              (Sent to Exchange-Handler Account)
    // [4] =
    // [5] = Packs                  (Stays in Contract, distributed via giveGumWithPack function)
    address[4] internal _reserveAccounts;
    uint256[6] internal _reserveRatios;

    bool internal _tokensDistributed;
    bool internal _reserveAccountsSet;

    mapping (address => bool) internal _isMigrated;

    constructor() public {


        // dist = (total * ratio) / 100
        _reserveRatios = [
            31,   // % of Total         930,000,000
            5,    //                    150,000,000
            5,    //                    150,000,000
            20,   //                    600,000,000
            5,    //                    150,000,000
            34    //                  1,020,000,000
        ];        //                -----------------
                  // Total            3,000,000,000
    }

    function setContractAddresses(
        CryptoCardsCardToken cards,
        CryptoCardsPackToken packs,
        CryptoCardsGumToken gum,
        CryptoCardsCards cryptoCardsCards,
        CryptoCardsPacks cryptoCardsPacks
    ) public onlyOwner {
        require(address(cards) != address(0), "Invalid cards address supplied");
        require(address(packs) != address(0), "Invalid packs address supplied");
        require(address(gum) != address(0), "Invalid gum address supplied");
        require(address(cryptoCardsCards) != address(0), "Invalid CryptoCards address supplied");
        require(address(cryptoCardsPacks) != address(0), "Invalid CryptoCardPacks address supplied");

        _cardToken = cards;
        _packToken = packs;
        _gumToken = gum;
        _cryptoCardsCards = cryptoCardsCards;
        _cryptoCardsPacks = cryptoCardsPacks;
    }

    function migrateMe() public {
        _migrate(msg.sender);
    }

    function migrateForOwner(address owner) public onlyOwner {
        _migrate(owner);
    }

    function migrateForOwners(address[] memory owners) public onlyOwner {
        for (uint256 i = 0; i < owners.length; i++) {
            _migrate(owners[i]);
        }
    }








    function setReserveAccounts(address[] memory accounts) public onlyOwner {
//        require(!_reserveAccountsSet, "Reserve Accounts already set");
//        require(accounts.length == 4, "Invalid accounts supplied; must be an array of length 4");
//
//        for (uint256 i = 0; i < 4; ++i) {
//            require(accounts[i] != address(0), "Invalid address supplied for reserve account");
//            _reserveAccounts[i] = accounts[i];
//        }
//        _reserveAccountsSet = true;
    }

    function distributeInitialGum() public onlyOwner {
//        require(_reserveAccountsSet, "Reserve accounts are not set");
//        require(!_tokensDistributed, "Tokens have already been distributed to reserve accounts");
//
//        uint256 totalSupply = _gumToken.totalSupply();
//        uint256 amount;
//        uint len = _reserveAccounts.length;
//        for (uint256 i = 0; i < len; ++i) {
//            amount = totalSupply * _reserveRatios[i] / 100;
//            _token.transfer(_reserveAccounts[i], amount);
//        }
//
//        saleGumAvailable = totalSupply * _reserveRatios[4] / 100;
//        packGumAvailable = totalSupply * _reserveRatios[5] / 100;
//
//        _tokensDistributed = true;
    }





    function _migrate(address owner) internal {
        require(_isMigrated[owner] == false, "Owner is already migrated");

        _migrateCardsForOwner(owner);
        _migratePacksForOwner(owner);
        _migrateGumForOwner(owner);

        _isMigrated[owner] = true;
    }

    function _migrateCardsForOwner(address owner) internal {
        //        uint256 tokenCount = _cardToken.balanceOf(owner);
        //        uint256 tokenId;
        //        string memory tokenData;
        //        for (uint256 i = 0; i < tokenCount; i++) {
        //            tokenId = _cardToken.tokenOfOwnerByIndex(i);
        //            tokenData = _cryptoCardsCards.cardHashById(tokenId);
        //
        //            // Mint New Token
        //            erc1155.mintCard(owner, tokenData);
        //
        //            // Freeze Old Token
        //            _cardToken.freezeToken(tokenId);
        //        }
    }

    function _migratePacksForOwner(address owner) internal {
        //        uint256 tokenCount = _packToken.balanceOf(owner);
        //        uint256 tokenId;
        //        string memory tokenData;
        //        string[] memory cardData;
        //        for (uint256 i = 0; i < tokenCount; i++) {
        //            tokenId = _packToken.tokenOfOwnerByIndex(i);
        //            tokenData = _cryptoCardsPacks.packDataById(tokenId);
        //            cardData = _parsePackData(tokenData);
        //
        //            // Mint New Token
        //            for (uint256 j = 0; j < cardData.length; j++) {
        //                erc1155.mintCard(owner, cardData[j]);
        //            }
        //
        //            // Freeze Old Token
        //            _packToken.freezeToken(tokenId);
        //        }
    }

    function _migrateGumForOwner(address owner) internal {
        //        uint256 tokenCount = _gumToken.balanceOf(owner);
        //        erc1155.mintGum(owner, tokenCount);
    }

    //    function _parsePackData(string memory packData) internal returns (string[] memory cardData) {
    //        strings.slice memory s = packData.toSlice();
    //        strings.slice memory d = ".".toSlice();
    //        for (uint256 i = 0; i < 8; i++) {
    //            cardData.push(s.split(d).toString());
    //        }
    //    }

}
