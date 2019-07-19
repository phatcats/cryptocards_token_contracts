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
networkName="local"

usage() {
    echo "usage: ./deploy.sh [[-n [local|ropsten|mainnet] [-f]] | [-h]]"
    echo "  -n | --network [local|ropsten|mainnet]    Deploys contracts to the specified network (default is local)"
    echo "  -f | --fresh                              Run all deployments from the beginning, instead of updating"
    echo "  -i | --initialize                         Run Contract Initializations"
    echo "  -h | --help                               Displays this help screen"
}

echoHeader() {
    echo " "
    echo "-----------------------------------------------------------"
    echo "-----------------------------------------------------------"
}

echoBeep() {
    afplay /System/Library/Sounds/Glass.aiff
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
    truffle compile --all

    echoHeader
    echo "Running Contract Migrations.."
    truffle migrate --reset -f 1 --to 2 --network "$networkName"

    echoHeader
    echo "Contract Deployment Complete!"
    echo " "
    echoBeep
}

runInitializations() {
    echoHeader
    echo "Running Contract Initializations..."
    truffle migrate -f 3 --to 3 --network "$networkName"
    echoBeep
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
else
    usage
fi
