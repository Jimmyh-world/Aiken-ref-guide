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
// This validator is parameterized with an OutputReference to a UTxO
// that must be consumed to authorize the mint.
validator one_shot_policy(utxo_ref: OutputReference) {
  mint(redeemer: Void, context: ScriptContext) -> Bool {
    let tx = context.transaction

    // 1. Ensure the unique UTxO is being spent
    let utxo_consumed = list.any(tx.inputs, fn(input) {
      input.output_reference == utxo_ref
    })

    // 2. (Optional) Validate the exact quantity and name of the minted asset
    let mint_amount = assets.quantity_of(tx.mint, context.purpose.policy_id, "MyNFT")

    and {
      utxo_consumed,
      mint_amount == 1, // Ensure only one NFT is minted
    }
  }
}
```

## Controlled Minting Pattern

This pattern allows for flexible minting and burning over time, controlled by an administrative key. It is suitable for fungible tokens where supply needs to be managed.

```aiken
type Action {
  Mint { token_name: ByteArray, amount: Int }
  Burn { token_name: ByteArray, amount: Int }
}

// This validator is parameterized with the admin's public key hash.
validator controlled_minting(admin: ByteArray) {
  mint(redeemer: Action, context: ScriptContext) -> Bool {
    let tx = context.transaction
    let policy_id = context.purpose.policy_id

    when redeemer is {
      Mint { token_name, amount } ->
        and {
          // 1. Check for admin signature
          list.has(tx.extra_signatories, admin),
          // 2. Ensure a positive amount is being minted
          amount > 0,
          // 3. Verify the transaction's mint value matches the redeemer
          assets.quantity_of(tx.mint, policy_id, token_name) == amount,
        }
      Burn { token_name, amount } ->
        // Anyone can burn their own tokens. The ledger ensures they own them.
        // The amount must be negative for burning.
        assets.quantity_of(tx.mint, policy_id, token_name) == -amount
    }
  }
}
```

## Security Considerations

- **Uniqueness for NFTs**: Always use the one-shot minting pattern for NFTs to guarantee scarcity and prevent fraudulent mints.
- **Admin Key Security**: In controlled minting patterns, the security of the entire token supply rests on the security of the admin's private key.
- **Burning Logic**: Ensure your burn logic cannot be exploited. Typically, allowing anyone to burn (create a negative mint value) is safe, as the ledger already requires them to own the tokens they are burning.

## Related Topics

- [Token Contract Example](../code-examples/token-contract.md)
- [Validators](../language/validators.md)

## References

- [Aiken Documentation: Minting Policies](https://aiken-lang.org/fundamentals/minting-policies)
