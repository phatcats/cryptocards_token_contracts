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

import "./CryptoCardsERC721.sol";

/**
 * @title Crypto-Cards ERC721 Pack Token
 * ERC721-compliant token representing individual Packs
 */
contract CryptoCardsPackToken is CryptoCardsERC721 {
    constructor() public CryptoCardsERC721("Crypto-Cards Packs", "PACKS") { }
}
