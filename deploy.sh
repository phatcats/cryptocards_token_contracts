#!/usr/bin/env bash

# Phat Cats - Crypto-Cards
#  - https://crypto-cards.io
#  - https://phatcats.co
#
# Copyright 2019 (c) Phat Cats, Inc.

# Ganache Local Accounts
#  - 1 = Contract Owner

freshLoad=
initialize=
migration=
networkName="local"

usage() {
    echo "usage: ./deploy.sh [[-n [local|ropsten|mainnet] [-f]] | [-h]]"
    echo "  -n | --network [local|ropsten|mainnet]    Deploys contracts to the specified network (default is local)"
    echo "  -f | --fresh                              Run all deployments from the beginning, instead of updating"
    echo "  -i | --initialize                         Run Contract Initializations"
    echo "  -m | --migrate                            Run Token Migration Script"
    echo "  -h | --help                               Displays this help screen"
}

echoHeader() {
    echo " "
    echo "-----------------------------------------------------------"
    echo "-----------------------------------------------------------"
}

deployFresh() {
    echoHeader
    echo "Deploying Token Contracts"
    echo " - using network: $networkName"

    echoHeader
    echo "Clearing previous build..."
    rm -rf build/

    echoHeader
    echo "Compiling Contracts.."
    truffle compile

    echoHeader
    echo "Running Contract Migrations.."
    truffle migrate --reset -f 1 --to 2 --network "$networkName"

    echoHeader
    echo "Contract Deployment Complete!"
    echo " "
}

runInitializations() {
    echoHeader
    echo "Running Contract Initializations..."
    truffle migrate -f 3 --to 3 --network "$networkName"
}

runMigrations() {
    echoHeader
    echo "Running Token Migrations..."
    truffle migrate -f 4 --to 4 --network "$networkName"
}


while [ "$1" != "" ]; do
    case $1 in
        -n | --network )        shift
                                networkName=$1
                                ;;
        -f | --fresh )          freshLoad="yes"
                                ;;
        -i | --initialize )     initialize="yes"
                                ;;
        -m | --migrate )        migration="yes"
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if [ -n "$freshLoad" ]; then
    deployFresh
elif [ -n "$initialize" ]; then
    runInitializations
elif [ -n "$migration" ]; then
    runMigrations
else
    usage
fi
