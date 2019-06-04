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
            oracleApiEndpoint: 'BAUD89qAzoJsLlajETu6INZFbd5GnNfeg6ZTJbe0hq2ltEOctlwLrsDuMTMffqEUMbGoioZEzjDqhu314KVzZFw9/IVnbar5mVxS/mhmSN+NfrDRXW5Sxpsdds+epmMiSJ+URKsSCAAGljpjoesWcukFmU2UPy1apKKU5OpKpGc3AzowXOViIaG4BXG++rWZ1NMv/xVjHQKqSYTHx4qlQAJH94RcZtoQuz4+x0PwJv/RUQ==',
            gas      : 6721975,
            gasPrice : 20000000000          // (20 Gwei)
        },
        ropsten: {
            oracleApiEndpoint: 'BL5iQLuZFIoMp3mXKb/Nt4C0cq/MDtCB6cZjYxve4bsvWzcvyWjp61XaENaMlc02cvbeK2jAohabMRXhj8q8jw1pFeSx8DQxkmMU0enzCqoxA/VcX2vvxJSuq71RmBTLfqT/+gu4tlHn1y7US2lGMYTCBI23775TkCKpS4c0Qe/KoHfxYAWFsWfcbKr0hcjMihobOJA7k0/8Jb3uaxA9Qf+92I/zQPwKVxY/RSXxdIU=',
            gas      : 8000000,
            gasPrice : 20000000000          // https://ropsten.etherscan.io/gastracker  (20 Gwei)
        },
        mainnet: {
            oracleApiEndpoint: 'BP00gRkhrJdkE9+lyEJmZZcmK1Pq1R6WpyZM1ZislsSxFhGo+YzxSOFT4/a9jfEbFlwKMog53Z6wMzem14mKXfvSQOklp1WpCit2KZ6nmTvGBx/96cpTXvtuH90eZglas5F9qPcv75tqSexG2Yb6zWVIwVV0C0sFXsElfg75Sf9tjyPgqaQuQOGxKhza1SUESziEYDy2onUbM12LBlL7H75nnyAoVpcdiMfGgMEGSrGZnsgM29uIxJmG',
            // For contract deployments
            // gas     : 8000000,           // https://etherscan.io/blocks
            // For contract interactions
            gas      : 1000000,             // https://etherscan.io/blocks
            gasPrice : 1000000000           // https://etherscan.io/gastracker  (1 Gwei)
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