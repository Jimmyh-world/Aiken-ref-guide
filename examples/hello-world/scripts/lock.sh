#!/bin/bash

# Hello World Validator Lock Script
# This script demonstrates locking tADA to the hello-world validator

set -e

# Configuration
NETWORK="testnet-magic 1097911063"  # Preprod testnet
AMOUNT="10000000"  # 10 ADA in lovelace
COLLATERAL_AMOUNT="5000000"  # 5 ADA for collateral

# Check if plutus.json exists
if [ ! -f "plutus.json" ]; then
    echo "❌ Error: plutus.json not found. Run ./scripts/build.sh first."
    exit 1
fi

# Check if cardano-cli is available
if ! command -v cardano-cli &> /dev/null; then
    echo "❌ Error: cardano-cli is not installed or not in PATH."
    exit 1
fi

echo "🔒 Locking tADA to Hello World Validator..."

# Generate keys if they don't exist
if [ ! -f "keys/payment.skey" ]; then
    echo "🔑 Generating payment keys..."
    mkdir -p keys
    cardano-cli address key-gen \
        --verification-key-file keys/payment.vkey \
        --signing-key-file keys/payment.skey
fi

# Generate address
if [ ! -f "keys/payment.addr" ]; then
    echo "📍 Generating payment address..."
    cardano-cli address build \
        --payment-verification-key-file keys/payment.vkey \
        --out-file keys/payment.addr \
        --testnet-magic 1097911063
fi

# Get validator hash
VALIDATOR_HASH=$(jq -r '.validators[0].hash' plutus.json)
echo "🔑 Validator hash: $VALIDATOR_HASH"

# Create datum
echo "📄 Creating datum..."
cardano-cli transaction hash-script-data \
    --script-data-value '{"constructor": 0, "fields": [{"bytes": "'$(cardano-cli address key-hash --payment-verification-key-file keys/payment.vkey)'"}]}' \
    --out-file datum.hash

# Build script address
echo "🏗️ Building script address..."
cardano-cli address build \
    --payment-script-file plutus.json \
    --out-file script.addr \
    --testnet-magic 1097911063

# Get UTxO for funding
echo "💰 Getting UTxO for funding..."
cardano-cli query utxo \
    --address $(cat keys/payment.addr) \
    --testnet-magic 1097911063 \
    --out-file utxo.json

# Calculate total available
TOTAL_AVAILABLE=$(jq -r '[.[] | .value.lovelace] | add' utxo.json 2>/dev/null || echo "0")

if [ "$TOTAL_AVAILABLE" -lt "$((AMOUNT + COLLATERAL_AMOUNT + 2000000))" ]; then
    echo "❌ Error: Insufficient funds. Need at least $((AMOUNT + COLLATERAL_AMOUNT + 2000000)) lovelace"
    echo "   Available: $TOTAL_AVAILABLE lovelace"
    echo "   Please fund your address: $(cat keys/payment.addr)"
    exit 1
fi

# Get protocol parameters
echo "📋 Getting protocol parameters..."
cardano-cli query protocol-parameters \
    --testnet-magic 1097911063 \
    --out-file protocol.json

# Build transaction
echo "🏗️ Building lock transaction..."
cardano-cli transaction build \
    --testnet-magic 1097911063 \
    --tx-in $(jq -r 'keys[0]' utxo.json) \
    --tx-out $(cat script.addr)+$AMOUNT \
    --tx-out-datum-hash $(cat datum.hash) \
    --tx-out $(cat keys/payment.addr)+$COLLATERAL_AMOUNT \
    --change-address $(cat keys/payment.addr) \
    --protocol-params-file protocol.json \
    --out-file lock.tx

# Sign transaction
echo "✍️ Signing transaction..."
cardano-cli transaction sign \
    --tx-body-file lock.tx \
    --signing-key-file keys/payment.skey \
    --testnet-magic 1097911063 \
    --out-file lock.signed

# Submit transaction
echo "📡 Submitting transaction..."
cardano-cli transaction submit \
    --tx-file lock.signed \
    --testnet-magic 1097911063

echo "✅ Successfully locked $AMOUNT lovelace to the Hello World validator!"
echo "📄 Transaction details:"
echo "   Script address: $(cat script.addr)"
echo "   Datum hash: $(cat datum.hash)"
echo "   Collateral UTxO: $(cat keys/payment.addr) + $COLLATERAL_AMOUNT lovelace"

# Clean up temporary files
rm -f utxo.json protocol.json lock.tx lock.signed

echo "💡 Next step: Run ./scripts/unlock.sh to spend the locked funds"

