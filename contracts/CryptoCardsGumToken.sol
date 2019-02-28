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

import "./CryptoCardsERC20.sol";

/**
 * @title Crypto-Cards ERC20 GUM Token
 * ERC20-compliant token representing Pack-Gum
 */
contract CryptoCardsGumToken is CryptoCardsERC20 {
    constructor() public CryptoCardsERC20("CryptoCards Gum", "GUM", 18, 3000000000 * (10**18)) { }

    // 3 Billion, Total Supply
    function mintTotalSupply(uint256 totalSupply, address initialHolder) public {
        _mint(initialHolder, totalSupply * (10**18));
    }
}
