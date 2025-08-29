# Token Minting Patterns

## Overview

This document covers common patterns for creating and managing custom tokens (both fungible and non-fungible) using Aiken minting policies.

## Problem Solved

These patterns provide standardized and secure ways to control the supply, distribution, and burning of on-chain assets.

## When to Use

- **NFTs**: Creating unique, one-of-a-kind digital assets.
- **Fungible Tokens**: For utility tokens, governance tokens, or stablecoins.
- **Access Control**: Using tokens to represent permissions or roles.

## One-Shot Minting Pattern

This pattern ensures that a specific token or collection of tokens can only be minted once. It is the standard for creating legitimate NFTs. The uniqueness is guaranteed by requiring a specific UTxO to be spent in the minting transaction.

```aiken
// Modern one-shot NFT policy with current Aiken patterns
use aiken/collection/list
use aiken/collection/dict
use cardano/assets
use cardano/transaction.{Transaction, OutputReference}

pub type NftAction {
  Mint { token_name: ByteArray }
  Burn { token_name: ByteArray }
}

// This validator is parameterized with an OutputReference to a UTxO
// that must be consumed to authorize the mint.
validator one_shot_policy(utxo_ref: OutputReference) {
  mint(redeemer: NftAction, _datum: Void, self: Transaction) -> Bool {
    when redeemer is {
      Mint { token_name } -> {
        // 1. Ensure the unique UTxO is being spent
        let utxo_consumed = list.any(self.inputs, fn(input) {
          input.output_reference == utxo_ref
        })

        // 2. Validate exactly one token is minted (total across all policies)
        let minted_value = assets.without_lovelace(self.mint)
        let policy_dict = assets.to_dict(minted_value)
        let total_minted = policy_dict
          |> dict.foldl(0, fn(_policy_id, asset_dict, acc) {
              acc + dict.foldl(asset_dict, 0, fn(_asset_name, quantity, sum) {
                sum + quantity
              })
            })

        // 3. Basic token validation
        let valid_token_name = token_name != ""

        and {
          utxo_consumed,        // Uniqueness guarantee
          total_minted == 1,    // Exactly one token
          valid_token_name,     // Non-empty name
        }
      }

      Burn { token_name } -> {
        // Burning logic with proper validation
        let minted_value = assets.without_lovelace(self.mint)
        let policy_dict = assets.to_dict(minted_value)
        let total_burned = policy_dict
          |> dict.foldl(0, fn(_policy_id, asset_dict, acc) {
              acc + dict.foldl(asset_dict, 0, fn(_asset_name, quantity, sum) {
                sum + quantity
              })
            })

        and {
          total_burned < 0,     // Must be negative for burning
          token_name != "",     // Valid token name
        }
      }
    }
  }

  else(_) {
    fail
  }
}
```

## Controlled Minting Pattern

This pattern allows for flexible minting and burning over time, controlled by an administrative key. It is suitable for fungible tokens where supply needs to be managed.

```aiken
// Modern controlled minting with proper admin verification
use aiken/collection/list
use aiken/collection/dict
use cardano/assets
use cardano/transaction.{Transaction}

pub type Action {
  Mint { token_name: ByteArray, amount: Int }
  Burn { token_name: ByteArray, amount: Int }
}

// This validator is parameterized with the admin's public key hash.
validator controlled_minting(admin: ByteArray) {
  mint(redeemer: Action, _datum: Void, self: Transaction) -> Bool {
    when redeemer is {
      Mint { token_name, amount } -> {
        // 1. SECURITY: Verify admin signature
        let admin_signed = list.has(self.extra_signatories, admin)

        // 2. SECURITY: Validate positive amount
        let positive_amount = amount > 0

        // 3. SECURITY: Validate token name
        let valid_token_name = token_name != ""

        // 4. SECURITY: Validate mint value (requires manual calculation)
        // Note: Without access to policy_id, use total quantity validation
        let minted_value = assets.without_lovelace(self.mint)
        let policy_dict = assets.to_dict(minted_value)
        let total_minted = policy_dict
          |> dict.foldl(0, fn(_policy_id, asset_dict, acc) {
              acc + dict.foldl(asset_dict, 0, fn(_asset_name, quantity, sum) {
                sum + quantity
              })
            })

        and {
          admin_signed,         // Admin must sign
          positive_amount,      // Positive amount required
          valid_token_name,     // Valid token name
          total_minted == amount, // Mint amount matches expectation
        }
      }

      Burn { token_name, amount } -> {
        // Anyone can burn their own tokens. The ledger ensures they own them.
        // The amount must be negative for burning.
        let valid_token_name = token_name != ""
        let negative_amount = amount < 0

        and {
          valid_token_name,
          negative_amount,
        }
      }
    }
  }

  else(_) {
    fail
  }
}
```

## Security Considerations

### **Critical Security Requirements**

- **Uniqueness for NFTs**: Always use the one-shot minting pattern for NFTs to guarantee scarcity and prevent fraudulent mints.
- **Admin Key Security**: In controlled minting patterns, the security of the entire token supply rests on the security of the admin's private key.
- **Modern Syntax**: Use `self: Transaction` instead of deprecated `context: ScriptContext` for current Aiken compatibility.

### **Implementation Security Notes**

- **Policy ID Access**: Modern Aiken doesn't provide direct access to `context.purpose.policy_id`. Use total quantity validation instead.
- **Signature Verification**: Always use `list.has(self.extra_signatories, admin)` for real signature checking.
- **Input Validation**: Validate all parameters (token names, amounts, quantities) before processing.
- **Burning Logic**: Ensure burn logic validates negative amounts. Typically, allowing anyone to burn is safe as the ledger requires token ownership.

### **Testing Requirements**

- **UTxO Consumption**: Test that the specific UTxO is actually consumed
- **Quantity Control**: Test that exactly the expected amount is minted
- **Security Failures**: Test that invalid signatures, amounts, or parameters fail validation
- **Edge Cases**: Test zero amounts, empty token names, and boundary conditions

### **Production Checklist**

- [ ] Use modern `self: Transaction` syntax
- [ ] Include proper imports (`aiken/collection/list`, `cardano/assets`, etc.)
- [ ] Add `aiken-lang/stdlib` dependency to `aiken.toml`
- [ ] Implement comprehensive test suite covering security scenarios
- [ ] Conduct security audit before mainnet deployment

## Related Topics

- [Token Contract Example](../code-examples/token-contract.md)
- [Validators](../language/validators.md)

## References

- [Aiken Documentation: Minting Policies](https://aiken-lang.org/fundamentals/minting-policies)
