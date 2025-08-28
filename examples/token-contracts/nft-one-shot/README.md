# NFT One-Shot Minting Policy

A production-ready example demonstrating a secure NFT minting policy that ensures exactly one NFT can be minted once, preventing re-mints and policy misuse.

## 🎯 What This Example Demonstrates

- **One-Shot Minting**: Exactly one NFT can be minted per policy
- **Reference UTxO Protection**: Prevents replay attacks using specific UTxO consumption
- **Time-Based Security**: Validity intervals prevent time-based attacks
- **Issuer Authorization**: Optional issuer signature requirement
- **Complete Security**: Comprehensive validation of all minting conditions

## 🔒 Security Features

### ✅ Security Checklist

- [x] **Exactly One Mint**: Enforces exactly one token per policy (no partials/multiples)
- [x] **Reference UTxO**: Specific UTxO must be consumed to prevent replay attacks
- [x] **Validity Window**: Time-based restrictions to reduce race conditions
- [x] **Issuer Signature**: Optional signer gate for additional security
- [x] **Token Name Validation**: Exact token name matching prevents confusion
- [x] **No Burning**: NFTs cannot be burned (policy always returns False for burns)
- [x] **Hash Stability**: Policy parameters are baked into the script for consistency

## 📋 Prerequisites

### Required Software

- **Aiken**: v1.1.14+ ([Installation Guide](https://aiken-lang.org/getting-started/installation))
- **Node.js**: v18+ (for MeshJS integration)
- **MeshJS**: Latest version (`npm install @meshsdk/core`)

### Network Access

- **Testnet Access**: This example uses Preprod testnet
- **Test ADA**: You'll need test ADA for transactions

## 🚀 Quick Start

### Build and Test

```bash
# 1. Build the policy
aiken build

# 2. Run tests
aiken test

# 3. Generate plutus.json
aiken blueprint convert
```

### Off-Chain Integration

```bash
# Install MeshJS
npm install @meshsdk/core

# Use the minting script
node offchain/mint.ts
```

## 📁 Project Structure

```
nft-one-shot/
├── aiken.toml                    # Project configuration
├── validators/
│   └── nft_policy.ak            # Main minting policy
├── lib/
│   └── nft_policy/
│       ├── helpers.ak           # Helper functions
│       └── tests.ak             # Comprehensive test suite
├── offchain/
│   └── mint.ts                  # MeshJS minting script
├── build/                       # Compiled artifacts
└── plutus.json                 # Policy script (generated)
```

## 🔍 How It Works

### Policy Parameters

The policy accepts these parameters (baked into the script):

```aiken
type NftPolicyParams {
  issuer: VerifierKeyHash,        // Who can mint (optional)
  reference_utxo: ByteArray,      // Specific UTxO that must be consumed
  token_name: ByteArray,          // Exact token name required
  valid_from: Int,                // Earliest slot for minting
  valid_until: Int,               // Latest slot for minting
}
```

### Validation Logic

The policy enforces these conditions:

1. **Quantity Validation**: `redeemer.quantity == 1`
2. **Time Validation**: Transaction within `valid_from` to `valid_until`
3. **Reference UTxO**: Specific UTxO must be consumed
4. **Issuer Signature**: Issuer must sign (if specified)
5. **Asset Validation**: Exactly one asset with correct name and quantity

### Minting Flow

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Setup Phase   │    │   Mint Phase    │    │   Success       │
│                 │    │                 │    │                 │
│ 1. Create       │───▶│ 1. Consume      │───▶│ NFT minted      │
│    reference    │    │    reference    │    │ to wallet       │
│    UTxO         │    │    UTxO         │    │                 │
│                 │    │                 │    │                 │
│ 2. Define       │    │ 2. Provide      │    │                 │
│    policy       │    │    redeemer     │    │                 │
│    parameters   │    │    (quantity=1) │    │                 │
│                 │    │                 │    │                 │
│ 3. Set validity │    │ 3. Issuer signs │    │                 │
│    window       │    │    transaction  │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🧪 Testing

### Run All Tests

```bash
aiken test
```

### Test Coverage

The test suite covers:

- ✅ **Success Cases**:
  - Valid mint with correct parameters
- ❌ **Failure Cases**:
  - Multiple tokens minted
  - Wrong token name
  - Missing issuer signature
  - Missing reference UTxO
  - Out of validity range
  - Burning attempts

### Test Output Example

```
Running 7 tests...
✓ valid_mint_succeeds
✓ multiple_tokens_fails
✓ wrong_token_name_fails
✓ missing_issuer_signature_fails
✓ missing_reference_utxo_fails
✓ out_of_validity_range_fails
✓ burning_fails

All tests passed! 🎉
```

## 🔧 Configuration

### Policy Parameters

```aiken
// Example policy parameters
let params = NftPolicyParams {
  issuer: Some(issuer_key_hash),
  reference_utxo: specific_utxo_id,
  token_name: "MyUniqueNFT",
  valid_from: 1000000,
  valid_until: 1100000,
}
```

### Customization Options

- **Issuer Requirement**: Set to `None` for no signature requirement
- **Validity Window**: Adjust based on your use case
- **Token Name**: Must match exactly what you want to mint
- **Reference UTxO**: Can be any UTxO you control

## 🚨 Common Errors & Solutions

### "Policy validation failed"

- Check all parameters match exactly
- Verify reference UTxO is being consumed
- Ensure issuer signature is present (if required)
- Confirm transaction is within validity window

### "Multiple assets minted"

- Ensure only one asset is being minted
- Check redeemer quantity is exactly 1

### "Wrong token name"

- Token name must match policy parameters exactly
- Check for case sensitivity and encoding

### "Reference UTxO not consumed"

- The specific UTxO must be included as an input
- Verify UTxO ID matches policy parameters

### "Out of validity range"

- Transaction must be submitted within the time window
- Check current slot vs. valid_from/valid_until

## 🔗 Integration Examples

### MeshJS Integration

```typescript
import { mintNftOneShot } from './offchain/mint';

// Connect wallet
const wallet = await connectWallet();

// Mint NFT
await mintNftOneShot(
  wallet,
  policyId,
  assetName,
  referenceUtxo,
  validFrom,
  validUntil
);
```

### PyCardano Integration

```python
# Example PyCardano integration
from pycardano import *

# Create policy
policy = NativeScript(
    script_hash=policy_hash,
    type="Native"
)

# Mint transaction
tx = TransactionBuilder()
tx.mint = MultiAsset.from_primitive({
    policy_hash: {
        asset_name: 1
    }
})
```

## 📝 Best Practices

### Security Considerations

1. **Reference UTxO Selection**: Choose a UTxO you control and can consume
2. **Validity Window**: Set reasonable time limits to prevent long-term attacks
3. **Issuer Signature**: Use issuer signatures for additional security
4. **Token Names**: Use unique, descriptive names to avoid conflicts
5. **Testing**: Always test on testnet before mainnet deployment

### Production Deployment

1. **Audit**: Have the policy audited by security experts
2. **Testing**: Comprehensive testing on testnet
3. **Documentation**: Document all parameters and requirements
4. **Monitoring**: Monitor minting transactions for anomalies

## 🔗 Related Resources

### Official Documentation

- [Aiken Language Reference](https://aiken-lang.org/language)
- [Cardano Native Tokens](https://docs.cardano.org/native-tokens/)
- [MeshJS Documentation](https://meshjs.dev/)

### Community Resources

- [Aiken Discord](https://discord.gg/aiken-lang)
- [Cardano Developer Portal](https://developers.cardano.org/)

## 📝 Copy-Me Template

To use this example as a template:

```bash
# Copy the example
cp -r examples/token-contracts/nft-one-shot/ my-nft-policy/

# Update configuration
cd my-nft-policy/
sed -i 's/nft-one-shot/my-nft-policy/' aiken.toml

# Start building!
aiken build
```

## 🤝 Contributing

Found an issue or have an improvement? Please:

1. Check existing issues
2. Create a new issue with clear description
3. Submit a pull request with tests

## 📄 License

Apache 2.0 - See [LICENSE](../../LICENSE) for details.

---

## Secure NFT minting made simple! 🚀
