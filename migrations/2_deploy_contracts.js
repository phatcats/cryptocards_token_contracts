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
const { networkOptions, opensea } = require('../config');
const _ = require('lodash');

const CryptoCardsPackToken = artifacts.require('CryptoCardsPackToken');
const CryptoCardsCardToken = artifacts.require('CryptoCardsCardToken');
const CryptoCardsGumToken = artifacts.require('CryptoCardsGumToken');


module.exports = async function(deployer, network, accounts) {
    let nonce = 0;

    Lib.network = (network || '').replace('-fork', '');
    if (_.isUndefined(networkOptions[Lib.network])) {
        Lib.network = 'local';
    }

    const owner = accounts[0]; // process.env[`${_.toUpper(Lib.network)}_OWNER_ACCOUNT`];
    const options = networkOptions[Lib.network];
    const proxyRegistryAddress = opensea.proxyRegistryAddress[Lib.network] || '';

    const _getTxOptions = () => {
        return {from: owner, nonce: nonce++, gasPrice: options.gasPrice};
    };

    Lib.log({msg: `Network:   ${Lib.network}`});
    Lib.log({msg: `Web3:      ${web3.version}`});
    Lib.log({msg: `Gas Price: ${Lib.fromWeiToGwei(options.gasPrice)} GWEI`});
    Lib.log({msg: `Owner:     ${owner}`});
    Lib.log({separator: true});

    try {
        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Get Transaction Nonce
        nonce = (await Lib.getTxCount(owner)) || 0;
        Lib.log({msg: `Starting at Nonce: ${nonce}`});
        Lib.log({separator: true});
        Lib.log({spacer: true});
        Lib.log({spacer: true});

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Deploy CryptoCardsCardToken
        Lib.log({spacer: true});
        Lib.log({msg: '-- CryptoCardsCardToken "CARD" --'});
        const cryptoCardsCardToken = await deployer.deploy(CryptoCardsCardToken, _getTxOptions());

        if (!_.isEmpty(proxyRegistryAddress)) {
            Lib.log({spacer: true});
            Lib.log({msg: 'Updating Cards Token with Proxy Registry Address for OpenSea...'});
            Lib.log({msg: `Proxy Registry: ${proxyRegistryAddress}`, indent: 1});
            await cryptoCardsCardToken.setProxyRegistryAddress(proxyRegistryAddress, _getTxOptions());
        }

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Deploy CryptoCardsPackToken
        Lib.log({spacer: true});
        Lib.log({msg: '-- CryptoCardsPackToken "PACK" --'});
        const cryptoCardsPackToken = await deployer.deploy(CryptoCardsPackToken, _getTxOptions());

        if (!_.isEmpty(proxyRegistryAddress)) {
            Lib.log({spacer: true});
            Lib.log({msg: 'Updating Packs Token with Proxy Registry Address for OpenSea...'});
            Lib.log({msg: `Proxy Registry: ${proxyRegistryAddress}`, indent: 1});
            await cryptoCardsPackToken.setProxyRegistryAddress(proxyRegistryAddress, _getTxOptions());
        }

        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Deploy CryptoCardsGumToken
        Lib.log({spacer: true});
        Lib.log({msg: '-- CryptoCardsGumToken "GUM" --'});
        const cryptoCardsGumToken = await deployer.deploy(CryptoCardsGumToken, _getTxOptions());


        // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        // Deploy Complete
        Lib.log({separator: true});
        Lib.log({separator: true});

        Lib.log({spacer: true});
        Lib.log({spacer: true});

        Lib.log({msg: 'Token Addresses:'});
        Lib.log({msg: `Packs:       ${cryptoCardsPackToken.address}`, indent: 1});
        Lib.log({msg: `Cards:       ${cryptoCardsCardToken.address}`, indent: 1});
        Lib.log({msg: `Gum:         ${cryptoCardsGumToken.address}`, indent: 1});
    }
    catch (err) {
        console.log(err);
    }
};
