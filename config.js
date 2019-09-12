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
            gasPrice : 20 * 1e8
        },
        ropsten: {
            // For contract deployments
            // gas                : 8000000,  // https://ropsten.etherscan.io/blocks
            // For contract interactions
            gas      : 1000000,
            gasPrice : 20 * 1e8             // https://ropsten.etherscan.io/gastracker
        },
        mainnet: {
            // For contract deployments
            // gas     : 8000000,           // https://etherscan.io/blocks
            // For contract interactions
            gas      : 1000000,             // https://etherscan.io/blocks
            gasPrice : 2 * 1e8              // https://etherscan.io/gastracker
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
