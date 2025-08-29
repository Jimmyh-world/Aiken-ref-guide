# Hello World Troubleshooting Guide

## Common Issues & Solutions

### ❌ "Plutus script error"

**Symptoms**: Transaction fails with script evaluation error
**Causes**:

- Wrong redeemer message (not exactly "Hello, World!")
- Missing owner signature in transaction
- Invalid datum format

**Solutions**:

1. **Verify redeemer is case-sensitive exact match**:

   ```bash
   # Correct
   "Hello, World!"

   # Wrong (common mistakes)
   "hello, world!"  # Wrong case
   "Hello World"    # Missing comma and exclamation
   " Hello, World! " # Extra spaces
   ```

2. **Ensure signing wallet matches datum owner PKH**:

   ```bash
   # Check datum owner
   cardano-cli transaction view --tx-body-file tx.body

   # Verify signing wallet matches
   cardano-cli address key-hash --payment-verification-key-file payment.vkey
   ```

3. **Check datum format**:
   ```json
   {
     "constructor": 0,
     "fields": [{ "bytes": "owner_public_key_hash_here" }]
   }
   ```

### ❌ "No UTxOs at script address"

**Symptoms**: Cannot find funds to unlock
**Solutions**:

1. **Run lock script first**:

   ```bash
   ./scripts/lock.sh
   ```

2. **Wait for confirmation** (1-2 minutes on testnet):

   ```bash
   cardano-cli query utxo --address $(cat plutus.json | jq -r '.address') --testnet-magic 1097911063
   ```

3. **Verify script address**:
   ```bash
   cardano-cli address build --payment-script-file plutus.json --testnet-magic 1097911063
   ```

### ❌ "Insufficient collateral"

**Symptoms**: Transaction fails with collateral error
**Solutions**:

1. **Ensure wallet has separate UTxO with 5+ ADA**:

   ```bash
   cardano-cli query utxo --address $(cat payment.addr) --testnet-magic 1097911063
   ```

2. **Don't use collateral UTxO as transaction input**:

   ```bash
   # Use different UTxO for collateral
   cardano-cli transaction build \
     --tx-in <input_utxo> \
     --tx-in-collateral <collateral_utxo> \
     --change-address $(cat payment.addr)
   ```

3. **Fund wallet from Preprod Faucet**:
   - Visit: https://docs.cardano.org/cardano-testnet/tools/faucet/
   - Request test ADA for your address

### ❌ "Network magic mismatch"

**Symptoms**: Connection errors or wrong network
**Solutions**:

- **Preprod**: `--testnet-magic 1097911063`
- **Preview**: `--testnet-magic 2`
- **Mainnet**: `--mainnet`

**Verify with**:

```bash
cardano-cli query tip --testnet-magic 1097911063
```

### ❌ "Invalid datum hash"

**Symptoms**: Transaction fails with datum hash mismatch
**Solutions**:

1. **Regenerate datum hash**:

   ```bash
   cardano-cli transaction hash-script-data --script-data-value '{"constructor": 0, "fields": [{"bytes": "owner_pkh"}]}'
   ```

2. **Use correct datum format**:

   ```bash
   # Create datum file
   echo '{"constructor": 0, "fields": [{"bytes": "owner_pkh"}]}' > datum.json

   # Use in transaction
   --tx-out-datum-hash-file datum.json
   ```

### ❌ "Script validation failed"

**Symptoms**: Script execution fails during validation
**Debugging Steps**:

1. **Check script compilation**:

   ```bash
   aiken check
   aiken build
   ```

2. **Verify script hash**:

   ```bash
   cardano-cli transaction policyid --script-file plutus.json
   ```

3. **Test with minimal transaction**:
   ```bash
   # Create simple test transaction
   cardano-cli transaction build \
     --tx-in <utxo> \
     --tx-in-script-file plutus.json \
     --tx-in-datum-value '{"constructor": 0, "fields": [{"bytes": "owner"}]}' \
     --tx-in-redeemer-value '{"constructor": 0, "fields": [{"bytes": "Hello, World!"}]}' \
     --change-address $(cat payment.addr) \
     --testnet-magic 1097911063
   ```

### ❌ "Mesh/PyCardano integration errors"

**Symptoms**: Off-chain tools fail to connect or execute
**Solutions**:

#### Mesh (TypeScript)

```bash
# Install dependencies
cd offchain && npm install

# Set environment variables
export HELLO_WORLD_SCRIPT_ADDRESS="addr_test1..."
export OWNER_PUBKEY_HASH="owner_pkh_here"

# Test connection
npm run utxos
```

#### PyCardano (Python)

```bash
# Install dependencies
cd offchain && pip install -r requirements.txt

# Set environment variables
export HELLO_WORLD_SCRIPT_ADDRESS="addr_test1..."
export OWNER_PUBKEY_HASH="owner_pkh_here"

# Test connection
python pycardano.py utxos
```

### ❌ "Build errors"

**Symptoms**: `aiken check` or `aiken build` fails
**Solutions**:

1. **Update Aiken**:

   ```bash
   cargo install aiken --git https://github.com/aiken-lang/aiken
   ```

2. **Check syntax**:

   ```bash
   aiken check --verbose
   ```

3. **Clean and rebuild**:
   ```bash
   rm -rf build/
   aiken check
   ```

### ❌ "Test failures"

**Symptoms**: `aiken test` fails
**Solutions**:

1. **Run specific test**:

   ```bash
   aiken test valid_hello_world_succeeds
   ```

2. **Check test dependencies**:

   ```bash
   # Ensure all modules are imported correctly
   aiken check
   ```

3. **Debug test logic**:
   ```bash
   # Add debug prints to tests
   aiken test --verbose
   ```

## Performance Issues

### ❌ "High execution units"

**Symptoms**: Transaction costs too much
**Solutions**:

1. **Optimize validation logic**:

   ```aiken
   // Use efficient string comparison
   redeemer.message == "Hello, World!"
   ```

2. **Minimize datum size**:

   ```aiken
   // Use compact datum format
   pub type HelloWorldDatum {
     owner: ByteArray, // Only essential data
   }
   ```

3. **Profile execution**:
   ```bash
   aiken check --verbose
   ```

## Network-Specific Issues

### Preprod Testnet

```bash
# Correct network parameters
--testnet-magic 1097911063
--cardano-mode
```

### Preview Testnet

```bash
# Correct network parameters
--testnet-magic 2
--cardano-mode
```

### Mainnet

```bash
# Correct network parameters
--mainnet
--cardano-mode
```

## Debugging Commands

### Check Script Status

```bash
# Verify script compilation
aiken check

# Check script address
cardano-cli address build --payment-script-file plutus.json

# View script details
cardano-cli transaction view --tx-body-file tx.body
```

### Check UTxOs

```bash
# Check script UTxOs
cardano-cli query utxo --address $(cat plutus.json | jq -r '.address')

# Check wallet UTxOs
cardano-cli query utxo --address $(cat payment.addr)
```

### Check Network

```bash
# Verify network connection
cardano-cli query tip

# Check protocol parameters
cardano-cli query protocol-parameters
```

## Getting Help

### 1. **Check Logs**

```bash
# Enable verbose logging
aiken check --verbose
cardano-cli transaction build --verbose
```

### 2. **Community Resources**

- [Aiken Documentation](https://aiken-lang.org/)
- [Cardano Developer Portal](https://developers.cardano.org/)
- [Stack Exchange](https://cardano.stackexchange.com/)

### 3. **Common Patterns**

- Always test on testnet first
- Use small amounts for testing
- Keep private keys secure
- Document your setup process

## Prevention Tips

1. **Always test thoroughly** before mainnet deployment
2. **Use consistent network parameters** across all commands
3. **Keep dependencies updated** (Aiken, cardano-cli, etc.)
4. **Document your setup** for future reference
5. **Use version control** for all scripts and configurations
