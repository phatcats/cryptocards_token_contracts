/**
 * Phat Cats - Crypto-Cards
 *  - https://crypto-cards.io
 *  - https://phatcats.co
 *
 * Copyright 2019 (c) Phat Cats, Inc.
 */
'use strict';

require('dotenv').config();

// Required by zos-lib when running from truffle
global.artifacts = artifacts;
global.web3 = web3;

const { Lib } = require('./common');
const { networkOptions } = require('../config');
const _ = require('lodash');

const CryptoCardsPackToken = artifacts.require('CryptoCardsPackToken');
const CryptoCardsCardToken = artifacts.require('CryptoCardsCardToken');
const CryptoCardsGumToken = artifacts.require('CryptoCardsGumToken');

const _totalGumSupply = 3000000000; // billion

const _contractAddress = {
    local: {
        packs : '0x22bb50a434e82716773cff9306c9f1d2fb65bfbc',
        cards : '0xea1b680ffda06832e8f7f67f33491e68098aa631',
        gum   : '0xec0c563acba3074b72b3365c15164ccbeced07cb'
    },
    ropsten: {
        packs : '0x6379844bb9458d88c75423c179f64beb3cbd6773',
        cards : '0x9da3653f8d56893383c2fcbb359674e441d3779e',
        gum   : '0x46d187ba4a979800807293b1fa77bb9e8a539dd7'
    },
    mainnet: {
        packs : '',
        cards : '',
        gum   : ''
    }
};

module.exports = async function(deployer, network, accounts) {
    let nonce = 0;
    let receipt;

    Lib.network = (network || '').replace('-fork', '');
    if (_.isUndefined(Lib.network) || _.isUndefined(networkOptions[Lib.network])) {
        Lib.network = 'local';
    }

    const owner = accounts[0];
    const options = networkOptions[Lib.network];
    const contractAddress = _contractAddress[Lib.network];

    const _getTxOptions = () => {
        return {from: owner, nonce: nonce++, gasPrice: options.gasPrice};
    };

    Lib.log({msg: `Network:   ${Lib.network}`});
    Lib.log({msg: `Web3:      ${web3.version}`});
    Lib.log({msg: `Gas Price: ${Lib.fromWeiToGwei(options.gasPrice)} GWEI`});
    Lib.log({msg: `Owner:     ${owner}`});
    Lib.log({separator: true});

    try {
        const cryptoCardsPackToken = await CryptoCardsPackToken.deployed();
        const cryptoCardsCardToken = await CryptoCardsCardToken.deployed();
        const cryptoCardsGumToken = await CryptoCardsGumToken.deployed();

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Get Transaction Nonce
        nonce = (await Lib.getTxCount(owner)) || 0;
        Lib.log({msg: `Starting at Nonce: ${nonce}`});
        Lib.log({separator: true});
        Lib.log({spacer: true});
        Lib.log({spacer: true});

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Mint Total Supply of GUM Tokens
        Lib.log({spacer: true});
        Lib.log({msg: '-- Mint Total Supply of GUM Tokens (ERC20) --'});
        Lib.log({msg: `Total Supply: ${_totalGumSupply}`, indent: 1});
        Lib.log({msg: `Gum Contract Address: ${contractAddress.gum}`, indent: 1});
        receipt = await cryptoCardsGumToken.mintTotalSupply(_totalGumSupply, contractAddress.gum, _getTxOptions());
        Lib.logTxResult(receipt);

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Set Packs Minter
        Lib.log({spacer: true});
        Lib.log({msg: '-- Add Pack Token-Minter --'});
        Lib.log({msg: `Packs Contract Address: ${contractAddress.packs}`, indent: 1});
        receipt = await cryptoCardsPackToken.addMinter(contractAddress.packs, _getTxOptions());
        Lib.logTxResult(receipt);

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Set Cards Minter
        Lib.log({spacer: true});
        Lib.log({msg: '-- Add Card Token-Minter --'});
        Lib.log({msg: `Cards Contract Address: ${contractAddress.cards}`, indent: 1});
        receipt = await cryptoCardsCardToken.addMinter(contractAddress.cards, _getTxOptions());
        Lib.logTxResult(receipt);

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Deploy Complete
        Lib.log({separator: true});
        Lib.log({separator: true});
    }
    catch (err) {
        console.log(err);
    }
};
