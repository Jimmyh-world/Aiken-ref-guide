#!/bin/bash

# Hello World Validator Unlock Script
# This script demonstrates spending from the hello-world validator

set -e

# Configuration
NETWORK="testnet-magic 1097911063"  # Preprod testnet

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

echo "🔓 Unlocking tADA from Hello World Validator..."

# Check if keys exist
if [ ! -f "keys/payment.skey" ]; then
    echo "❌ Error: Payment keys not found. Run ./scripts/lock.sh first."
    exit 1
fi

# Get script address
if [ ! -f "script.addr" ]; then
    echo "🏗️ Building script address..."
    cardano-cli address build \
        --payment-script-file plutus.json \
        --out-file script.addr \
        --testnet-magic 1097911063
fi

# Get UTxO at script address
echo "💰 Getting UTxO at script address..."
cardano-cli query utxo \
    --address $(cat script.addr) \
    --testnet-magic 1097911063 \
    --out-file script_utxo.json

# Check if there are funds to unlock
SCRIPT_UTXO_COUNT=$(jq 'length' script_utxo.json)
if [ "$SCRIPT_UTXO_COUNT" -eq 0 ]; then
    echo "❌ Error: No UTxOs found at script address."
    echo "   Script address: $(cat script.addr)"
    echo "   Run ./scripts/lock.sh first to lock funds."
    exit 1
fi

# Get payment address UTxO for collateral
echo "💰 Getting payment address UTxO for collateral..."
cardano-cli query utxo \
    --address $(cat keys/payment.addr) \
    --testnet-magic 1097911063 \
    --out-file payment_utxo.json

# Get protocol parameters
echo "📋 Getting protocol parameters..."
cardano-cli query protocol-parameters \
    --testnet-magic 1097911063 \
    --out-file protocol.json

# Create redeemer
echo "📄 Creating redeemer..."
cardano-cli transaction hash-script-data \
    --script-data-value '{"constructor": 0, "fields": [{"bytes": "48656c6c6f2c20576f726c6421"}]}' \
    --out-file redeemer.hash

# Get the first UTxO from script address
SCRIPT_TXIN=$(jq -r 'keys[0]' script_utxo.json)
SCRIPT_AMOUNT=$(jq -r '.["'$SCRIPT_TXIN'"].value.lovelace' script_utxo.json)

# Get collateral UTxO
COLLATERAL_TXIN=$(jq -r 'keys[0]' payment_utxo.json)
COLLATERAL_AMOUNT=$(jq -r '.["'$COLLATERAL_TXIN'"].value.lovelace' payment_utxo.json)

echo "📊 Transaction details:"
echo "   Script UTxO: $SCRIPT_TXIN ($SCRIPT_AMOUNT lovelace)"
echo "   Collateral UTxO: $COLLATERAL_TXIN ($COLLATERAL_AMOUNT lovelace)"

# Build transaction
echo "🏗️ Building unlock transaction..."
cardano-cli transaction build \
    --testnet-magic 1097911063 \
    --tx-in $SCRIPT_TXIN \
    --tx-in-script-file plutus.json \
    --tx-in-datum-value '{"constructor": 0, "fields": [{"bytes": "'$(cardano-cli address key-hash --payment-verification-key-file keys/payment.vkey)'"}]}' \
    --tx-in-redeemer-value '{"constructor": 0, "fields": [{"bytes": "48656c6c6f2c20576f726c6421"}]}' \
    --tx-in $COLLATERAL_TXIN \
    --tx-out $(cat keys/payment.addr)+$((SCRIPT_AMOUNT - 2000000)) \
    --change-address $(cat keys/payment.addr) \
    --protocol-params-file protocol.json \
    --out-file unlock.tx

# Sign transaction
echo "✍️ Signing transaction..."
cardano-cli transaction sign \
    --tx-body-file unlock.tx \
    --signing-key-file keys/payment.skey \
    --testnet-magic 1097911063 \
    --out-file unlock.signed

# Submit transaction
echo "📡 Submitting transaction..."
cardano-cli transaction submit \
    --tx-file unlock.signed \
    --testnet-magic 1097911063

echo "✅ Successfully unlocked $SCRIPT_AMOUNT lovelace from the Hello World validator!"
echo "📄 Transaction details:"
echo "   Redeemer: 'Hello, World!'"
echo "   Signer: $(cat keys/payment.addr)"
echo "   Amount unlocked: $((SCRIPT_AMOUNT - 2000000)) lovelace (minus fees)"

# Clean up temporary files
rm -f script_utxo.json payment_utxo.json protocol.json unlock.tx unlock.signed redeemer.hash

echo "🎉 Hello World validator demonstration completed successfully!"
