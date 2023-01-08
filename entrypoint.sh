#!/bin/bash
set -e

NETWORK_ID=${CHAIN_ID:-'1900'}
PASSWORD=${NODE_PASSWORD}
GAS_LIMIT=${GAS_LIMIT}
ENV_FOLDER='data'

NODE_WALLET_ADDRESS=${NODE_WALLET_ADDRESS}
NODE_WALLET_PRIVATE_KEY=${NODE_WALLET_PRIVATE_KEY}
NODE_WALLET_BALANCE=${NODE_WALLET_BALANCE}

DEPLOYER_WALLET_ADDRESS=${DEPLOYER_WALLET_ADDRESS}
DEPLOYER_WALLET_PRIVATE_KEY=${DEPLOYER_WALLET_PRIVATE_KEY}
DEPLOYER_WALLET_BALANCE=${DEPLOYER_WALLET_BALANCE}

AGENT_WALLET_ADDRESS=${AGENT_WALLET_ADDRESS}
AGENT_WALLET_PRIVATE_KEY=${AGENT_WALLET_PRIVATE_KEY}
AGENT_WALLET_BALANCE=${AGENT_WALLET_BALANCE}

echo "[1] Generating genesis configuration"
cat > instanbul.toml <<-END
vanity = "0x00"
validators = ["$NODE_WALLET_ADDRESS"]
END

# echo $(instabul extra encode --config instanbul.toml)

cat > genesis.json <<-END
{
  "config": {
    "chainId": $NETWORK_ID,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0,
    "muirGlacierBlock": 0,
    "berlinBlock": 0,
    "londonBlock": 0,
    "arrowGlacierBlock": 0,
    "grayGlacierBlock": 0,
    "clique": {
      "period": 5,
      "epoch": 30000
    }
  },
  "difficulty": "1",
  "gasLimit": "$GAS_LIMIT",
  "extradata": "0x0000000000000000000000000000000000000000000000000000000000000000${NODE_WALLET_ADDRESS#"0x"}0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000",
  "alloc": {
    "$NODE_WALLET_ADDRESS": { "balance": "$NODE_WALLET_BALANCE" },
    "$DEPLOYER_WALLET_ADDRESS": { "balance": "$DEPLOYER_WALLET_BALANCE" },
    "$AGENT_WALLET_ADDRESS": { "balance": "$AGENT_WALLET_BALANCE" }
  }
}
END

mkdir -p $ENV_FOLDER

echo "$PASSWORD" > $ENV_FOLDER/pwd.txt
echo "$NODE_WALLET_PRIVATE_KEY" > node.pkey
echo "$DEPLOYER_WALLET_PRIVATE_KEY" > deployer.pkey
echo "$AGENT_WALLET_PRIVATE_KEY" > agent.pkey

echo "[2] Initializing first accounts for this node"

echo "[2.1] Importing node key"
geth account import --datadir $ENV_FOLDER --password $ENV_FOLDER/pwd.txt node.pkey 2> /dev/null
echo "[2.1] Importing deployer key"
geth account import --datadir $ENV_FOLDER --password $ENV_FOLDER/pwd.txt deployer.pkey 2> /dev/null
echo "[2.1] Importing agent key"
geth account import --datadir $ENV_FOLDER --password $ENV_FOLDER/pwd.txt agent.pkey 2> /dev/null
geth init --datadir $ENV_FOLDER genesis.json

echo "[3] Initializing node"
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
    --datadir $ENV_FOLDER \
    --nat "any" \
    --targetgaslimit "$GAS_LIMIT" \
    --unlock $NODE_WALLET_ADDRESS \
    --password "$ENV_FOLDER/pwd.txt" \
    --etherbase $NODE_WALLET_ADDRESS \
    --mine

echo "[4] Unlocking accounts"
geth attach --exec "personal.unlockAccount('$DEPLOYER_WALLET_ADDRESS', '123456', 300)" http://0.0.0.0:8545/
geth attach --exec "personal.unlockAccount('$AGENT_WALLET_ADDRESS', '123456', 300)" http://0.0.0.0:8545/