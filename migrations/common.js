/**
 * Phat Cats - Crypto-Cards
 *  - https://crypto-cards.io
 *  - https://phatcats.co
 *
 * Copyright 2019 (c) Phat Cats, Inc.
 */
'use strict';

const _ = require('lodash');
const fs = require('fs');

const Lib = {};

Lib.network = '';

Lib.promisify = (fn) => (...args) => new Promise((resolve, reject) => {
    fn(...args, (err, result) => {
        if (err) {
            reject(err);
        } else {
            resolve(result);
        }
    });
});

Lib.fromFinneyToWei = (value) => web3.utils.toWei(value.toString(), 'finney');
Lib.fromWeiToGwei = (value) => web3.utils.fromWei(value.toString(), 'gwei');
Lib.fromWeiToEther = (value) => web3.utils.fromWei(value.toString(), 'ether');
Lib.fromFinneyToEther = (value) => web3.utils.fromWei(Lib.fromFinneyToWei(value), 'ether');

Lib.ethTxCount = Lib.promisify(web3.eth.getTransactionCount);
Lib.getTxCount = (owner) => Lib.ethTxCount(owner);

Lib.log = ({msg, indent = 0, spacer = false, separator = false}) => {
    const msgArr = [];
    if (indent > 0) {
        const indentLevel = _.times(indent, _.constant('--')).join('');
        msgArr.push(' ', indentLevel);
    } else if (spacer) {
        msgArr.push(' ');
    } else if (separator) {
        msgArr.push('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
    } else {
        msgArr.push('[Deployer]')
    }
    if (!spacer && !separator) {
        msgArr.push(msg);
    }
    console.log(msgArr.join(' '));
};

Lib.logTxResult = (result) => {
    if (result.receipt) {
        Lib.log({msg: `TX hash:      ${result.tx}`, indent: 2});
        Lib.log({msg: `TX status:    ${result.receipt.status}`, indent: 2});
        Lib.log({msg: `TX gas used:  ${result.receipt.gasUsed}`, indent: 2});
    } else if (result.gasUsed) {
        Lib.log({msg: `TX gas used:  ${result.gasUsed}`, indent: 2});
    }
    Lib.log({spacer: true});
};

Lib.delay = (timeout) => new Promise((resolve) => {
    setTimeout(() => { resolve(); }, timeout);
});

Lib.readStateFile = (stateObj = {filename: '', data: {}}) => {
    if (_.isEmpty(_.get(stateObj, 'filename', ''))) {
        throw new Error('No "filename" provided on "stateObj" when calling "Lib.readStateFile"');
    }
    if (!fs.existsSync(stateObj.filename)) {
        Lib.writeStateFile(stateObj);
    }
    _.set(stateObj, 'data', JSON.parse(fs.readFileSync(stateObj.filename, 'utf-8')));
};

Lib.writeStateFile = (stateObj) => {
    return fs.writeFileSync(stateObj.filename, JSON.stringify(stateObj.data, null, '\t'));
};

Lib.getDeployedAddresses = (network) => {
    if (network === 'dev-5777') { network = 'local'; }
    // Store in parent dir so that other repos can read it
    const stateObj = {filename: `../contract-addresses-${network}.json`, data: {}};
    Lib.readStateFile(stateObj);
    return stateObj;
};

Lib.setDeployedAddresses = (deployState) => {
    return Lib.writeStateFile(deployState);
};

Lib.getContractInstance = (contract, contractAddress) => {
    // Dirty hack for web3@1.0.0 support for localhost testrpc,
    // see https://github.com/trufflesuite/truffle-contract/issues/56#issuecomment-331084530
    if (typeof contract.currentProvider.sendAsync !== "function") {
        contract.currentProvider.sendAsync = function () {
            return contract.currentProvider.send.apply(contract.currentProvider, arguments);
        };
    }
    return contract.at(contractAddress);
};

module.exports = { Lib };
