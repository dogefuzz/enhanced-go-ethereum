#!/bin/sh

NETWORK_ID=${CHAIN_ID:-'1900'}

geth \
    --fast \
    --identity "TestNode2" \
    --rpc \
    -rpcaddr "0.0.0.0" \
    --rpcport "8545" \
    --rpccorsdomain "*" \
    --port "30303" \
    --nodiscover  \
    --rpcapi "db,eth,net,web3,miner,net,personal,net,txpool,admin" \
    --networkid $NETWORK_ID \
    --datadir $ENVIRONMENT_FOLDER \
    --nat "any" \
    --targetgaslimit "9000000000000" \
    --unlock 0 \
    --password "$ENVIRONMENT_FOLDER/pwd.txt" \
    --mine 