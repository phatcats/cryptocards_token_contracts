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
        packs : '0xe08960423ff6ba89efcbca0b061712e1f3039fb1',
        cards : '0x88050054406ce9a28032a285dee3cd82f9babda3',
        gum   : '0x001fb4dc08b9326ec15264ddbd718b249570c0a8'
    },
    mainnet: {
        packs : '0x9fe807eadeb031b133c099165c00cff519c32ac6',
        cards : '0xe10f8f13addda57869cdf800aab4c0d5de9fa585',
        gum   : '0x0a0c04e27c466e2dfc85eac947930a1fbc0cb6f3'
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
