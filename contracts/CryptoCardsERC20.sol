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

import "./ERC20.sol";

/**
 * @title Crypto-Cards ERC20 Token
 */
contract CryptoCardsERC20 is ERC20 {
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;
    uint256 internal _cap;

    constructor(string memory name, string memory symbol, uint8 decimals, uint256 cap) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
        _cap = cap;
    }

    function getVersion() public pure returns (string memory) {
        return "v2.1.2";
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @return the maximum number of tokens.
     */
    function cap() public view returns (uint256) {
        return _cap;
    }


    function _mint(address account, uint256 value) internal {
        require(totalSupply().add(value) <= _cap, "Exceeds token cap");
        super._mint(account, value);
    }
}
