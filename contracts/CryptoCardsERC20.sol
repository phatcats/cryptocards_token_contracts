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
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Capped.sol";


/**
 * @title Crypto-Cards ERC20 Token
 */
contract CryptoCardsERC20 is Ownable, ERC20Detailed, ERC20Capped {
    constructor(string memory name, string memory symbol, uint8 decimals, uint256 tokenCap)
        public
        ERC20Detailed(name, symbol, decimals)
        ERC20Capped(tokenCap)
    {}
}
