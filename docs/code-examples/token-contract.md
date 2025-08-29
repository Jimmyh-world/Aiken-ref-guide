# Token Contract Examples

## Overview

This document provides complete code examples for two common token minting scenarios in Aiken: a one-shot NFT policy and a fungible token policy with administrative controls.

## Key Concepts

- **Minting Policy**: A validator with a `mint` handler that controls the creation and destruction of tokens under a specific `PolicyId`.
- **One-Shot Policy**: Guarantees uniqueness by consuming a specific UTxO, making it ideal for NFTs.
- **Controlled Policy**: Uses an administrative key to manage the minting of fungible tokens over time.

---

## Example 1: One-Shot NFT Minting Policy

This policy ensures that an NFT can only be minted once.

### `validators/nft_policy.ak`

```aiken
// Modern one-shot NFT policy reflecting actual working implementation
use aiken/collection/list
use aiken/collection/dict
use cardano/assets
use cardano/transaction.{OutputReference, Transaction}

// The redeemer defines minting/burning actions with token names
pub type NftAction {
  Mint { token_name: ByteArray }
  Burn { token_name: ByteArray }
}

// The validator is parameterized with the UTxO that must be spent.
validator one_shot_nft(utxo_ref: OutputReference) {
  mint(redeemer: NftAction, _datum: Void, self: Transaction) -> Bool {
    when redeemer is {
      Mint { token_name } -> {
        // 1. SECURITY: Ensure the unique UTxO is being consumed
        let utxo_consumed = list.any(self.inputs, fn(input) {
          input.output_reference == utxo_ref
        })

        // 2. SECURITY: Validate exactly one token is minted (total across all policies)
        let minted_value = assets.without_lovelace(self.mint)
        let policy_dict = assets.to_dict(minted_value)
        let total_minted = policy_dict
          |> dict.foldl(0, fn(_policy_id, asset_dict, acc) {
              acc + dict.foldl(asset_dict, 0, fn(_asset_name, quantity, sum) { 
                sum + quantity 
              })
            })

        // 3. SECURITY: Basic validation that we're minting something
        let valid_token_name = token_name != ""

        and {
          utxo_consumed,        // UTxO reference consumed (uniqueness)
          total_minted == 1,    // Exactly 1 token minted total
          valid_token_name,     // Valid token name
        }
      }
      
      Burn { token_name } -> {
        // SECURITY: Burning is allowed - ledger ensures user owns the tokens
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

---

## Example 2: Controlled Fungible Token

This policy allows an admin to mint new tokens and anyone to burn their own tokens.

### `validators/fungible_token.ak`

```aiken
use aiken/list

// The redeemer defines the actions.
pub type Action {
  Mint { receiver: ByteArray, amount: Int }
  Burn
}

// The validator is parameterized with the admin's public key hash.
validator(admin_pkh: ByteArray) {
  mint(redeemer: Action, context: ScriptContext) -> Bool {
    let tx = context.transaction
    let policy_id = context.purpose.policy_id

    when redeemer is {
      Mint { amount, .. } -> {
        // 1. Check for the admin's signature.
        let admin_signed = list.has(tx.extra_signatories, admin_pkh)

        // 2. Check that a positive amount is being minted.
        let positive_amount = amount > 0

        and {
          admin_signed,
          positive_amount,
        }
      }
      Burn -> {
        // Burning is unrestricted by the script.
        True
      }
    }
  }
}
```

## Related Topics

- [Token Minting Patterns](../patterns/token-minting.md)
- [Validators](../language/validators.md)
- [Getting Started](../overview/getting-started.md)

## References

- [Aiken Documentation: Minting Policies](https://aiken-lang.org/fundamentals/minting-policies)
