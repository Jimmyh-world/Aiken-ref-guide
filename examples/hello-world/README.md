# Hello World Validator

A simple, production-ready example demonstrating the basic eUTxO model in Aiken. This validator locks tADA and only allows spending when the correct redeemer message is provided AND the owner signs the transaction.

## 🎯 What This Example Demonstrates

- **Basic eUTxO Model**: Lock → Spend flow
- **Datum Validation**: Owner public key hash stored in datum
- **Redeemer Validation**: Must provide "Hello, World!" message
- **Signature Verification**: Owner must sign the spending transaction
- **Complete Workflow**: Build → Lock → Spend with real cardano-cli commands

## 📋 Prerequisites

### Required Software
- **Aiken**: v1.8.0+ ([Installation Guide](https://aiken-lang.org/getting-started/installation))
- **cardano-cli**: Latest version ([Cardano Docs](https://docs.cardano.org/cardano-node/install/))
- **jq**: JSON processor (usually pre-installed on Linux/macOS)

### Network Access
- **Testnet Access**: This example uses Preprod testnet
- **Test ADA**: You'll need test ADA for transactions (get from [faucet](https://docs.cardano.org/cardano-testnet/tools/faucet/))

## 🚀 Quick Start

### One-Command Path

```bash
# 1. Build the validator
./scripts/build.sh

# 2. Lock tADA to the validator
./scripts/lock.sh

# 3. Spend from the validator
./scripts/unlock.sh
```

### Manual Steps

If you prefer to understand each step:

```bash
# Build and check
aiken check
aiken build
aiken blueprint convert

# Run tests
aiken test
```

## 📁 Project Structure

```
hello-world/
├── aiken.toml              # Project configuration
├── validators/
│   └── hello_world.ak      # Main validator logic
├── lib/
│   └── hello_world/
│       ├── hello_world.ak  # Helper functions
│       └── tests.ak        # Comprehensive test suite
├── scripts/
│   ├── build.sh            # Build and compile validator
│   ├── lock.sh             # Lock tADA to validator
│   └── unlock.sh           # Spend from validator
├── keys/                   # Generated keys (created by scripts)
├── build/                  # Compiled artifacts
└── plutus.json            # Validator script (generated)
```

## 🔍 How It Works

### eUTxO Flow Diagram

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Lock Phase    │    │   Spend Phase   │    │   Success       │
│                 │    │                 │    │                 │
│ 1. Create datum │───▶│ 1. Provide      │───▶│ Funds unlocked  │
│    (owner PKH)  │    │    redeemer     │    │ to owner        │
│                 │    │    "Hello,      │    │                 │
│ 2. Lock tADA    │    │    World!"      │    │                 │
│    to script    │    │                 │    │                 │
│                 │    │ 2. Owner signs  │    │                 │
│ 3. Script       │    │    transaction  │    │                 │
│    address      │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Validator Logic

The validator enforces two conditions:

1. **Redeemer Validation**: `redeemer.message == "Hello, World!"`
2. **Signature Validation**: `context.transaction.is_signed_by(datum.owner)`

Both conditions must be true for the transaction to succeed.

## 🧪 Testing

### Run All Tests
```bash
aiken test
```

### Test Coverage
The test suite covers:

- ✅ **Success Cases**:
  - Correct redeemer + owner signature
- ❌ **Failure Cases**:
  - Wrong redeemer message
  - Missing owner signature
  - No signatures
  - Wrong redeemer + wrong signer
  - Empty message
  - Case-sensitive validation

### Test Output Example
```
Running 7 tests...
✓ correct_redeemer_and_owner_succeeds
✓ wrong_redeemer_fails
✓ missing_owner_signature_fails
✓ no_signatures_fails
✓ wrong_redeemer_and_wrong_signer_fails
✓ empty_message_fails
✓ case_sensitive_message_fails

All tests passed! 🎉
```

## 🔧 Configuration

### Network Settings
The scripts are configured for **Preprod testnet**:
- Network Magic: `1097911063`
- Lock Amount: `10 ADA` (10,000,000 lovelace)
- Collateral: `5 ADA` (5,000,000 lovelace)

### Customization
Edit the scripts to change:
- Network (mainnet/testnet)
- Lock amounts
- Collateral amounts
- Fee calculations

## 🚨 Common Errors & Solutions

### "Aiken is not installed"
```bash
# Install Aiken
curl -sSfL https://aiken-lang.org/install.sh | sh
```

### "cardano-cli is not installed"
```bash
# Install cardano-node (includes cardano-cli)
# Follow: https://docs.cardano.org/cardano-node/install/
```

### "Insufficient funds"
- Get test ADA from the [faucet](https://docs.cardano.org/cardano-testnet/tools/faucet/)
- Ensure you have enough for lock amount + collateral + fees

### "No UTxOs found at script address"
- Run `./scripts/lock.sh` first to lock funds
- Check the script address is correct

### "Transaction failed"
- Verify you're using the correct network
- Check protocol parameters are up to date
- Ensure sufficient collateral

### "Invalid datum/redeemer"
- The datum must contain the owner's public key hash
- The redeemer must be exactly `"Hello, World!"` (case-sensitive)

## 🔗 Related Resources

### Official Documentation
- [Aiken Hello World Tutorial](https://aiken-lang.org/example--hello-world/end-to-end/cardano-cli)
- [Aiken Language Reference](https://aiken-lang.org/language)
- [Cardano CLI Documentation](https://docs.cardano.org/cardano-node/reference/)

### Community Resources
- [MeshJS Aiken Integration](https://meshjs.dev/guides/aiken)
- [Aiken Discord](https://discord.gg/aiken-lang)

## 📝 Copy-Me Template

To use this example as a template for your own project:

```bash
# Copy the entire example
cp -r examples/hello-world/ my-new-validator/

# Update the project name in aiken.toml
cd my-new-validator/
sed -i 's/hello-world/my-new-validator/' aiken.toml

# Start building!
./scripts/build.sh
```

## 🤝 Contributing

Found an issue or have an improvement? Please:

1. Check existing issues
2. Create a new issue with clear description
3. Submit a pull request with tests

## 📄 License

Apache 2.0 - See [LICENSE](../../LICENSE) for details.

---

**Happy coding! 🚀**
