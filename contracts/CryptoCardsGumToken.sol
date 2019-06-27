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

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/access/roles/MinterRole.sol";
import "./CryptoCardsERC20.sol";

/**
 * @title Crypto-Cards ERC20 GUM Token
 * ERC20-compliant token representing Pack-Gum
 */
contract CryptoCardsGumToken is CryptoCardsERC20, MinterRole, Ownable {
    constructor() public CryptoCardsERC20("Crypto-Cards Gum", "GUM", 18, 3000000 * (10**18)) {}

    // 3 Billion, Total Supply
    //  - initialHolder = CryptoCardsGumDistribution Contract
    function mintTotalSupply(uint256 totalSupply, address initialHolder) public onlyOwner {
        _mint(initialHolder, totalSupply * (10**18));
    }

    function transferFor(address from, address to, uint256 value) public onlyMinter {
        _transfer(from, to, value);
    }

//    function fastTransferFor(address to, uint256 value) public onlyMinter {
//        _fastTransfer(msg.sender, to, value);
//    }
}
