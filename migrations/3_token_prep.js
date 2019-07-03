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
const { networkOptions, contractAddresses } = require('../config');
const _ = require('lodash');

const CryptoCardsPackToken = artifacts.require('CryptoCardsPackToken');
const CryptoCardsCardToken = artifacts.require('CryptoCardsCardToken');
const CryptoCardsGumToken = artifacts.require('CryptoCardsGumToken');

const _totalGumSupply = 3000000; // million

module.exports = async function(deployer, network, accounts) {
    let nonce = 0;
    let receipt;

    Lib.network = (network || '').replace('-fork', '');
    if (_.isUndefined(Lib.network) || _.isUndefined(networkOptions[Lib.network])) {
        Lib.network = 'local';
    }

    const owner = accounts[0];
    const options = networkOptions[Lib.network];
    const contractAddress = contractAddresses[Lib.network];

    const _getTxOptions = () => {
        return {from: owner, nonce: nonce++, gasPrice: options.gasPrice};
    };

    Lib.log({msg: `Network:   ${Lib.network}`});
    Lib.log({msg: `Web3:      ${web3.version}`});
    Lib.log({msg: `Gas Price: ${Lib.fromWeiToGwei(options.gasPrice)} GWEI`});
    Lib.log({msg: `Owner:     ${owner}`});
    Lib.log({separator: true});

    try {
        const cryptoCardsPackToken = await CryptoCardsPackToken.deployed(); // .at('0x0683e840ea22b089dafa0bf8c59f1a9690de7c12');
        const cryptoCardsCardToken = await CryptoCardsCardToken.deployed(); // .at('0xcb35d14759e2931022c7315f53e37cdcd38e570c');
        const cryptoCardsGumToken = await CryptoCardsGumToken.deployed(); // .at('0xaAFa4Bf1696732752a4AD4D27DD1Ea6793F24Fc0');

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
        Lib.log({msg: `Initial Holder (Token Migrator): ${contractAddress.migrator}`, indent: 1});
        receipt = await cryptoCardsGumToken.mintTotalSupply(_totalGumSupply, contractAddress.migrator, _getTxOptions());
        Lib.logTxResult(receipt);

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Set Packs Minter
        Lib.log({spacer: true});
        Lib.log({msg: '-- Add Pack Token-Minter --'});
        Lib.log({msg: `Packs Contract Address: ${contractAddress.packsCtrl}`, indent: 1});
        receipt = await cryptoCardsPackToken.addMinter(contractAddress.packsCtrl, _getTxOptions());
        Lib.logTxResult(receipt);
        Lib.log({msg: `Migrator Contract Address: ${contractAddress.migrator}`, indent: 1});
        receipt = await cryptoCardsPackToken.addMinter(contractAddress.migrator, _getTxOptions());
        Lib.logTxResult(receipt);

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Set Cards Minter
        Lib.log({spacer: true});
        Lib.log({msg: '-- Add Card Token-Minter --'});
        Lib.log({msg: `Packs Contract Address: ${contractAddress.packsCtrl}`, indent: 1});
        receipt = await cryptoCardsCardToken.addMinter(contractAddress.packsCtrl, _getTxOptions());
        Lib.logTxResult(receipt);
        Lib.log({msg: `Cards Contract Address: ${contractAddress.cardsCtrl}`, indent: 1});
        receipt = await cryptoCardsCardToken.addMinter(contractAddress.cardsCtrl, _getTxOptions());
        Lib.logTxResult(receipt);
        Lib.log({msg: `Migrator Contract Address: ${contractAddress.migrator}`, indent: 1});
        receipt = await cryptoCardsCardToken.addMinter(contractAddress.migrator, _getTxOptions());
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
