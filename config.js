/**
 * Phat Cats - Crypto-Cards
 *  - https://crypto-cards.io
 *  - https://phatcats.co
 *
 * Copyright 2019 (c) Phat Cats, Inc.
 */

const config = {
    wallets: {
        ropsten: {
            apiEndpoint: `https://ropsten.infura.io/v3/${process.env.ROPSTEN_INFURA_API_KEY}`,
            mnemonic: {
                owner: process.env.ROPSTEN_WALLET_MNEMONIC_OWNER
            },
            accountIndex: 2
        },
        mainnet: {
            apiEndpoint: `https://mainnet.infura.io/v3/${process.env.MAINNET_INFURA_API_KEY}`,
            mnemonic: {
                owner: process.env.MAINNET_WALLET_MNEMONIC_OWNER
            },
            accountIndex: 1
        }
    },

    networkOptions: {
        local: {
            gas      : 6721975,
            gasPrice : 20000000000          // (20 Gwei)
        },
        ropsten: {
            gas      : 8000000,
            gasPrice : 30000000000          // https://ropsten.etherscan.io/gastracker
        },
        mainnet: {
            // For contract deployments
            // gas     : 8000000,           // https://etherscan.io/blocks
            // For contract interactions
            gas      : 1000000,             // https://etherscan.io/blocks
            gasPrice : 1000000000           // https://etherscan.io/gastracker  (1 Gwei)
        }
    },

    contractAddresses: {
        local: {
            packsCtrl : '0xA51A7dD583669a958059362dF2601197d8eE3B39',
            cardsCtrl : '0xfBb58f952c6e86DA1719c5257b89E6C07B78c23f',
            gumCtrl   : '0x22BB50A434E82716773cFF9306c9F1D2FB65bFBC',
            migrator  : '0xeE09F9b736d151732740Db085eD31E59bbFffD15'
        },
        ropsten: {
            packsCtrl : '0xaBcd7DdDcC8c82D3E515c05a9584e4027be6aBB7',
            cardsCtrl : '0xD1213702A38B08EB0498C54e6859bEadCF9f3bF1',
            gumCtrl   : '0xb06A8a73eAA6314BF2C762f918c6F21A5145fd3c',
            migrator  : '0xdeB4eA8EB68B009d3e5fEeCE4769EEc1a64a12f0'
        },
        mainnet: {
            packsCtrl : '',
            cardsCtrl : '',
            gumCtrl   : '',
            migrator  : ''
        }
    },

    // OpenSea proxy registry addresses for rinkeby and mainnet.
    opensea: {
        proxyRegistryAddress: {
            rinkby: '0xf57b2c51ded3a29e6891aba85459d600256cf317',
            mainnet: '0xa5409ec958c83c3f309868babaca7c86dcb077c1'
        }
    }
};

config.wallets['ropsten-fork'] = config.wallets['ropsten'];
config.networkOptions['ropsten-fork'] = config.networkOptions['ropsten'];

module.exports = config;
