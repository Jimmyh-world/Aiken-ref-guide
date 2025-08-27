# Deployment

## Overview

Deploying an Aiken smart contract involves compiling the code, generating the script address, and interacting with it on a network. This guide covers the steps for deploying to a testnet using `cardano-cli` and provides a checklist for mainnet deployment.

## Key Concepts

- **Blueprint (`plutus.json`)**: The compiled output of your Aiken project, containing the validator's CBOR hex.
- **Validator Hash**: The unique identifier for your compiled script.
- **Script Address**: A Cardano address derived from the validator hash where UTxOs can be locked.
- **`cardano-cli`**: The command-line interface for interacting with the Cardano network.

## Testnet Deployment Steps

### 1. Compile the Contract

First, build your Aiken project to generate the `plutus.json` blueprint.

```bash
aiken build
```

### 2. Generate the Script Address

Use `cardano-cli` to create the script address from the compiled code in the blueprint. You can use a tool like `jq` to extract the CBOR hex.

```bash
# Extract the compiled code from the blueprint
aiken_cbor=$(jq -r '.validators.compiledCode' plutus.json)

# Create a script file for cardano-cli
echo '{
    "type": "PlutusScriptV2",
    "description": "My Aiken Validator",
    "cborHex": "'$aiken_cbor'"
}' > validator.plutus

# Build the address (replace --testnet-magic with --mainnet for mainnet)
cardano-cli address build \
  --payment-script-file validator.plutus \
  --testnet-magic 2 \
  --out-file validator.addr

echo "Script address: $(cat validator.addr)"
```

### 3. Lock Funds in the Contract

To use the contract, you must send a transaction that locks a UTxO at the script address, with an inline datum.

```bash
# Assumes you have a funded wallet address in wallet.addr and its UTxO in $WALLET_UTXO
# Assumes your datum is correctly formatted in datum.json

cardano-cli transaction build \
  --babbage-era \
  --testnet-magic 2 \
  --tx-in $WALLET_UTXO \
  --tx-out "$(cat validator.addr) + 10000000" \
  --tx-out-inline-datum-file datum.json \
  --change-address $(cat wallet.addr) \
  --out-file lock-tx.raw

# Sign and submit the transaction
cardano-cli transaction sign ...
cardano-cli transaction submit ...
```

## Mainnet Deployment Checklist

Deploying to mainnet requires extreme caution. Follow this checklist:

- [ ] **Comprehensive Testing**: All contract logic has been exhaustively tested on a public testnet.
- [ ] **Security Audit**: The contract has been audited by at least one reputable third-party security firm.
- [ ] **Peer Review**: The code has been reviewed by other experienced Aiken developers.
- [ ] **Off-Chain Code Ready**: All off-chain components (backend, frontend) are complete and tested.
- [ ] **Parameter Verification**: All validator parameters (e.g., admin keys, fees) are correct for mainnet.
- [ ] **Monitoring Plan**: You have a plan and tools in place to monitor contract activity post-deployment.
- [ ] **Emergency Plan**: You have a documented procedure for responding to any discovered vulnerabilities or issues.

## Related Topics

- [Off-chain Tools](./offchain-tools.md)
- [Monitoring](./monitoring.md)
- [Audit Checklist](../security/audit-checklist.md)

## References

- [Cardano CLI Documentation](https://developers.cardano.org/docs/get-started/cardano-cli)
