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
use aiken/list
use cardano/transaction.{OutputReference}

// The redeemer defines the two possible actions: Mint or Burn.
pub type Action {
  Mint
  Burn
}

// The validator is parameterized with the UTxO that must be spent.
validator(utxo_ref: OutputReference) {
  mint(redeemer: Action, context: ScriptContext) -> Bool {
    let tx = context.transaction
    let policy_id = context.purpose.policy_id

    when redeemer is {
      Mint -> {
        // 1. Ensure the unique UTxO is being spent.
        let utxo_consumed = list.any(tx.inputs, fn(input) {
          input.output_reference == utxo_ref
        })

        // 2. Ensure only one token is minted (with any name).
        let minted_value = assets.without_lovelace(tx.mint)
        let total_minted =
          minted_value
            |> assets.to_map
            |> dict.values
            |> list.foldl(0, fn(acc, assets_map) {
              acc + list.foldl(dict.values(assets_map), 0, fn(sum, q) { sum + q })
            })

        and {
          utxo_consumed,
          total_minted == 1,
        }
      }
      Burn -> {
        // Burning is always allowed. The ledger ensures the user owns the tokens.
        True
      }
    }
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
