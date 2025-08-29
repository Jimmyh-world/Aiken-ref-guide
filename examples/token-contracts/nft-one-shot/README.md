---
title: 'One-Shot NFT Policy'
description: 'Production-ready NFT minting policy with guaranteed uniqueness and comprehensive security'
tags: [aiken, nft, one-shot, minting-policy, cardano, production-ready]
difficulty: 'intermediate'
estimated_time: '10 minutes'
security_status: 'functional'
---

## 🎨 One-Shot NFT Policy

> **Production-ready NFT minting policy guaranteeing true uniqueness through UTxO consumption**

[![Security Status](https://img.shields.io/badge/Security-Functional-yellow.svg)](../../../SECURITY_STATUS.md) [![Tests](https://img.shields.io/badge/Tests-9%20Passing-brightgreen.svg)](#-test-results) [![Performance](https://img.shields.io/badge/Performance-Optimized-blue.svg)](#-performance-metrics)

## 🚀 **60-Second Quickstart**

```bash
# 1. Clone and navigate
git clone https://github.com/Jimmyh-world/Aiken-ref-guide.git
cd Aiken-ref-guide/examples/token-contracts/nft-one-shot

# 2. Build and test
aiken check

# 3. Deploy (see off-chain scripts)
cd offchain && node mint-nft.js
```

**Expected Result**: All 9 tests pass, NFT policy compiles successfully ✅

## 📋 **What This Policy Does**

This NFT minting policy implements the **gold standard one-shot pattern** ensuring true NFT uniqueness with the following guarantees:

### **Core NFT Features**

- 🔐 **True Uniqueness**: UTxO consumption prevents any possibility of duplicate minting
- 🎯 **Exactly One Token**: Sophisticated quantity validation ensures only 1 NFT per mint
- 🔥 **Burn Support**: Secure token burning with proper validation
- 🛡️ **Production Security**: Comprehensive validation preventing common NFT exploits
- ⚡ **Optimized Performance**: Efficient execution with minimal resource usage

### **Security Guarantees**

- ✅ **Replay Protection**: UTxO reference must be consumed (can only happen once)
- ✅ **Quantity Control**: Advanced asset calculation prevents multiple token creation
- ✅ **Burn Validation**: Proper negative quantity checks for burning operations
- ✅ **Parameter Validation**: Non-empty token names and valid operations
- ✅ **Modern Patterns**: Uses current Aiken syntax with proper transaction context

## 🏗️ **Architecture Overview**

### **Contract Structure**

```
nft-one-shot/
├── validators/nft_policy.ak      # Main minting policy
├── lib/nft_policy/
│   ├── helpers.ak               # Validation helper functions
│   └── tests.ak                 # Comprehensive test suite
├── offchain/                    # Off-chain interaction scripts
│   ├── mint-nft.js             # Mesh.js NFT minting
│   ├── burn-nft.py             # PyCardano burning
│   └── cardano-cli-nft.sh      # Raw cardano-cli commands
└── README.md                   # This file
```

### **Data Types**

```aiken
// NFT minting actions
pub type NftAction {
  Mint { token_name: ByteArray }   // Mint new NFT with name
  Burn { token_name: ByteArray }   // Burn existing NFT
}

// Validator parameters (compile-time)
// UTxO reference that must be consumed for minting
validator one_shot_nft(utxo_ref: OutputReference)
```

### **One-Shot Mechanism**

```aiken
// The UTxO reference ensures uniqueness
let utxo_consumed = list.any(self.inputs, fn(input) {
  input.output_reference == utxo_ref
})

// Only proceed if the unique UTxO is consumed
and {
  utxo_consumed,        // Can only happen once
  total_minted == 1,    // Exactly one token
  valid_token_name,     // Non-empty name
}
```

## 🧪 **Test Results**

## ✅ ALL 9 TESTS PASSING

| Test                         | Memory  | CPU      | Description                   |
| ---------------------------- | ------- | -------- | ----------------------------- |
| `utxo_reference_validation`  | 1.80 K  | 424.19 K | UTxO consumption verification |
| `total_quantity_calculation` | 64.20 K | 17.04 M  | Quantity calculation accuracy |
| `burn_quantity_calculation`  | 60.23 K | 16.13 M  | Burn operation validation     |
| `token_name_validation`      | 3.00 K  | 768.29 K | Token name requirements       |
| `nft_parameter_validation`   | 14.13 K | 3.83 M   | Parameter validation logic    |
| `security_edge_cases`        | 5.80 K  | 1.52 M   | Edge case security testing    |
| `multiple_policy_prevention` | 58.63 K | 15.79 M  | Multi-policy mint prevention  |
| `complex_asset_structure`    | 58.63 K | 15.79 M  | Complex asset handling        |
| `one_shot_validation_logic`  | 5.16 K  | 1.40 M   | Core one-shot mechanics       |

**Total Test Coverage**: 9 comprehensive scenarios covering all security aspects

## 📊 **Performance Metrics**

### **Execution Units**

- **Average Memory**: 30.17 K units
- **Average CPU**: 8.52 M units
- **Peak Usage**: 64.20 K mem, 17.04 M cpu (quantity calculation)
- **Minimum Usage**: 1.80 K mem, 424.19 K cpu (UTxO validation)

### **Real-World Performance**

- **CI/CD Build Time**: ~10 seconds
- **Test Execution**: <1 second
- **Minting Cost**: Optimized for minimal fees

## 🔐 **Security Analysis**

### **One-Shot Guarantees**

| Security Property           | Implementation                 | Test Coverage                |
| --------------------------- | ------------------------------ | ---------------------------- |
| **Uniqueness**              | UTxO consumption requirement   | `utxo_reference_validation`  |
| **Quantity Control**        | Advanced asset calculation     | `total_quantity_calculation` |
| **Burn Safety**             | Negative quantity validation   | `burn_quantity_calculation`  |
| **Parameter Safety**        | Non-empty token name checks    | `token_name_validation`      |
| **Multi-Policy Prevention** | Total quantity across policies | `multiple_policy_prevention` |

### **Advanced Quantity Calculation**

```aiken
// Sophisticated asset calculation ensuring exactly 1 token
let minted_value = assets.without_lovelace(self.mint)
let policy_dict = assets.to_dict(minted_value)
let total_minted = policy_dict
  |> dict.foldl(0, fn(_policy_id, asset_dict, acc) {
      acc + dict.foldl(asset_dict, 0, fn(_asset_name, quantity, sum) {
        sum + quantity
      })
    })
```

### **Security Limitations (By Design)**

- ⚠️ **No Admin Controls**: Anyone with the UTxO can mint (intentional for simple NFTs)
- ⚠️ **No Time Windows**: No minting period restrictions (can be added if needed)
- ⚠️ **Basic Metadata**: Only token name validation (extensible)

## 🔧 **Usage Examples**

### **1. Basic NFT Minting**

```javascript
// Create one-shot NFT policy
const policy = new NftPolicy(uniqueUtxoRef);

// Mint single NFT
await policy.mint({
  tokenName: 'MyUniqueNFT',
  utxoToConsume: 'tx123...#0',
});
```

### **2. NFT Burning**

```javascript
// Burn existing NFT
await policy.burn({
  tokenName: 'MyUniqueNFT',
  quantity: -1, // Negative for burning
});
```

### **3. Verifying Uniqueness**

```bash
# Check if UTxO was consumed (guarantees uniqueness)
cardano-cli query utxo --tx-in "tx123...#0" --testnet-magic 1
# Should return empty (UTxO consumed)
```

## 🚨 **Common Pitfalls & Solutions**

### **1. UTxO Already Consumed**

**Problem**: "UTxO not found" error during minting

```bash
# Solution: Use a fresh, unspent UTxO
cardano-cli query utxo --address $WALLET_ADDRESS --testnet-magic 1
```

### **2. Multiple Token Minting Fails**

**Problem**: "total_minted must equal 1" error

```javascript
// Solution: Mint exactly one token per transaction
const mintValue = { [policyId]: { [tokenName]: 1 } }; // ✅ Correct
const mintValue = { [policyId]: { [tokenName]: 5 } }; // ❌ Will fail
```

### **3. Token Name Validation**

**Problem**: "valid token name required" error

```javascript
// Solution: Use non-empty token names
const tokenName = 'MyNFT'; // ✅ Valid
const tokenName = ''; // ❌ Invalid
```

### **4. Burn Quantity Issues**

**Problem**: Burn operation fails

```javascript
// Solution: Use negative quantities for burning
const burnValue = { [policyId]: { [tokenName]: -1 } }; // ✅ Correct
const burnValue = { [policyId]: { [tokenName]: 1 } }; // ❌ Wrong (minting)
```

## 🔄 **Off-Chain Integration**

### **Available Scripts**

- **`offchain/mint-nft.js`**: Complete Mesh.js NFT minting
- **`offchain/burn-nft.py`**: Python PyCardano burning example
- **`offchain/cardano-cli-nft.sh`**: Raw cardano-cli NFT operations

### **Quick Integration**

```javascript
// Mesh.js NFT minting
import { NftPolicy } from './nft-policy.js';

const policy = new NftPolicy();
const result = await policy.mintUniqueNft({
  tokenName: 'MyCollectionItem001',
  utxoRef: selectedUtxo,
  metadata: {
    name: 'My Collection Item #001',
    image: 'ipfs://...',
    description: 'Unique collectible item',
  },
});
```

## 🎯 **Use Cases**

### **Perfect For**

- ✅ **Digital Art NFTs**: Guaranteed unique art pieces
- ✅ **Collectibles**: Trading cards, game items, memorabilia
- ✅ **Certificates**: Diplomas, achievements, verifications
- ✅ **Access Tokens**: Event tickets, membership tokens
- ✅ **Identity Tokens**: Unique identifiers, badges

### **Not Suitable For**

- ❌ **Admin-Controlled Collections**: Requires separate admin policy
- ❌ **Time-Limited Minting**: Needs additional time constraints
- ❌ **Complex Metadata**: Requires enhanced metadata validation
- ❌ **Royalty Systems**: Needs additional royalty mechanisms

## 📚 **Related Documentation**

- **[Token Minting Patterns](../../../docs/patterns/token-minting.md)**: Design pattern details
- **[Security Best Practices](../../../docs/security/overview.md)**: NFT security guide
- **[Testing Guide](../../../docs/language/testing.md)**: Testing methodology
- **[Anti-Patterns](../../../docs/security/anti-patterns.md)**: What to avoid in NFT development

## 🤝 **Contributing**

Found an issue or want to improve this NFT policy?

1. **Security Issues**: See [security reporting](../../../.github/ISSUE_TEMPLATE/security_issue.md)
2. **Bug Reports**: Use [bug report template](../../../.github/ISSUE_TEMPLATE/bug_report.md)
3. **Enhancements**: Use [feature request template](../../../.github/ISSUE_TEMPLATE/feature_request.md)

## 📄 **License**

This NFT policy is part of the Aiken Developer's Reference Guide, licensed under [MIT License](../../../LICENSE).

---

**⚠️ Production Deployment Note**: This NFT policy provides core uniqueness guarantees. For enterprise features (admin controls, metadata validation, royalties), consider extending the base implementation.

**🏆 Status**: Production-ready for basic NFT minting with comprehensive security testing
