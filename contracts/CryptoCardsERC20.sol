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

    // Avoid 'Double Withdrawal Attack"
    // see:
    //  - https://docs.google.com/document/d/1YLPtQxZu1UAvO9cZ1O2RPXBbT0mooh4DYKjA_jp-RLM/
    //  - https://docs.google.com/document/d/1Feh5sP6oQL1-1NHi-X1dbgT3ch2WdhbXRevDN681Jv4/
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(this));
        super._transfer(from, to, value);
    }
}
