# Aiken Validators

## Overview

Validators are the core of Aiken smart contracts. They are on-chain scripts that define the logic for validating transactions related to spending UTxOs, minting tokens, and other ledger events.

## Key Concepts

- **`validator` Keyword**: Defines a new validator script.
- **Handlers**: Special functions within a validator that handle different ledger actions (`spend`, `mint`, `withdraw`, etc.).
- **`Transaction`**: Direct access to transaction information including inputs, outputs, and signatories.
- **Required Imports**: Modern Aiken validators require importing the standard library for transaction operations.
- **Return Value**: Every validator handler must return a `Bool`. `True` indicates success, and `False` indicates failure.
- **Parameters**: Validators can be parameterized with values known at compile time for reusability.

## Validator Structure

A validator is defined using the `validator` keyword, followed by a block containing one or more handlers.

```aiken
// Required imports for modern Aiken validators
use aiken/collection/list
use cardano/transaction.{Transaction, OutputReference}

validator my_script {
  // A minting handler
  mint(redeemer: Data, self: Transaction) -> Bool {
    // Minting logic - can access self.mint for minting info
    True
  }

  // A spending handler  
  spend(datum: Option<Data>, redeemer: Data, _own_ref: OutputReference, self: Transaction) -> Bool {
    // Spending logic - can access self.extra_signatories, self.outputs, etc.
    True
  }
}
```

## Handler Types and Signatures

Aiken supports handlers for all Plutus script purposes.

| Handler    | Description                            | Arguments (Modern Syntax)                           |
| ---------- | -------------------------------------- | --------------------------------------------------- |
| `spend`    | Validates spending a UTxO.             | `(datum, redeemer, own_ref, self: Transaction)`     |
| `mint`     | Validates minting or burning tokens.   | `(redeemer, self: Transaction)`                     |
| `withdraw` | Validates withdrawing staking rewards. | `(redeemer, self: Transaction)`                     |
| `publish`  | Validates publishing a certificate.    | `(redeemer, self: Transaction)`                     |
| `else`     | A fallback for unsupported purposes.   | `(self: Transaction)`                               |

## Parameterized Validators

Validators can be parameterized with compile-time data, making them highly reusable.

```aiken
// This minting policy is parameterized with a specific UTxO reference
// to ensure it can only be used once.
validator one_shot_policy(utxo_ref: OutputReference) {
  mint(_: Void, context: ScriptContext) -> Bool {
    let tx = context.transaction
    // Ensure the specific UTxO is consumed in the transaction
    list.any(tx.inputs, fn(input) {
      input.output_reference == utxo_ref
    })
  }
}
```

## Security Considerations

- **Typed Arguments**: Always use custom types for datums and redeemers instead of the generic `Data` type. This leverages Aiken's type system to prevent deserialization errors.
- **Transaction Validation**: Thoroughly inspect the `Transaction` object (the `self` parameter) to validate all necessary conditions. Check `self.extra_signatories`, `self.outputs`, `self.inputs`, etc.
- **Fail Explicitly**: If a condition is not met, ensure the validator returns `False`. Use `fail` or `_ -> False` in `when` clauses to handle invalid states.
- **Import Requirements**: Always import required modules (`aiken/collection/list`, `cardano/transaction`, etc.) and include stdlib dependency in `aiken.toml`.

## Practical Transaction Validation Examples

### Signature Verification
```aiken
use aiken/collection/list
use cardano/transaction.{Transaction, OutputReference}

validator secure_contract {
  spend(datum: Option<ByteArray>, redeemer: Data, _own_ref: OutputReference, self: Transaction) -> Bool {
    when datum is {
      Some(owner) -> {
        // Check if owner signed the transaction
        list.has(self.extra_signatories, owner)
      }
      None -> False
    }
  }
}
```

### Payment Validation
```aiken
use aiken/collection/list
use cardano/transaction.{Transaction, OutputReference, Output}
use cardano/address.{VerificationKey}
use cardano/assets.{ada_policy_id, ada_asset_name, quantity_of}

fn check_payment(outputs: List<Output>, recipient: ByteArray, min_amount: Int) -> Bool {
  list.any(outputs, fn(output) {
    when output.address.payment_credential is {
      VerificationKey(hash) -> {
        let ada_amount = quantity_of(output.value, ada_policy_id, ada_asset_name)
        hash == recipient && ada_amount >= min_amount
      }
      _ -> False
    }
  })
}
```

### Required Project Setup
Every Aiken project using modern transaction validation must include the standard library:

**aiken.toml:**
```toml
[[dependencies]]
name = "aiken-lang/stdlib"
version = "2.1.0"
source = "github"
```

## Related Topics

- [Data Structures](./data-structures.md)
- [Control Flow](./control-flow.md)
- [State Machine Pattern](../patterns/state-machines.md)

## References

- [Aiken Fundamentals: Validators](https://aiken-lang.org/fundamentals/validators)
