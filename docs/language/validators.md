# Aiken Validators

## Overview

Validators are the core of Aiken smart contracts. They are on-chain scripts that define the logic for validating transactions related to spending UTxOs, minting tokens, and other ledger events.

## Key Concepts

- **`validator` Keyword**: Defines a new validator script.
- **Handlers**: Special functions within a validator that handle different ledger actions (`spend`, `mint`, `withdraw`, etc.).
- **`ScriptContext`**: A built-in type that provides information about the transaction being validated.
- **Return Value**: Every validator handler must return a `Bool`. `True` indicates success, and `False` indicates failure.
- **Parameters**: Validators can be parameterized with values known at compile time for reusability.

## Validator Structure

A validator is defined using the `validator` keyword, followed by a block containing one or more handlers.

```aiken
validator my_script {
  // A minting handler
  mint(redeemer: Data, context: ScriptContext) -> Bool {
    // Minting logic
    True
  }

  // A spending handler
  spend(datum: Data, redeemer: Data, context: ScriptContext) -> Bool {
    // Spending logic
    True
  }
}
```

## Handler Types and Signatures

Aiken supports handlers for all Plutus script purposes.

| Handler    | Description                            | Arguments                    |
| ---------- | -------------------------------------- | ---------------------------- |
| `spend`    | Validates spending a UTxO.             | `(datum, redeemer, context)` |
| `mint`     | Validates minting or burning tokens.   | `(redeemer, context)`        |
| `withdraw` | Validates withdrawing staking rewards. | `(redeemer, context)`        |
| `publish`  | Validates publishing a certificate.    | `(redeemer, context)`        |
| `else`     | A fallback for unsupported purposes.   | `(context)`                  |

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
- **Context is Key**: Thoroughly inspect the `ScriptContext` to validate all necessary conditions of the transaction. Do not make assumptions about the transaction's structure.
- **Fail Explicitly**: If a condition is not met, ensure the validator returns `False`. Use `fail` or `_ -> False` in `when` clauses to handle invalid states.

## Related Topics

- [Data Structures](./data-structures.md)
- [Control Flow](./control-flow.md)
- [State Machine Pattern](../patterns/state-machines.md)

## References

- [Aiken Fundamentals: Validators](https://aiken-lang.org/fundamentals/validators)
