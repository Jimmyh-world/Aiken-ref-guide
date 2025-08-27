# Quick Reference

## Overview

This document provides quick reference tables for common Aiken syntax, CLI commands, and validation patterns.

---

### Common Imports

| Module                  | Common Functions                                        | Purpose               |
| ----------------------- | ------------------------------------------------------- | --------------------- |
| `aiken/collection/list` | `length`, `map`, `filter`, `foldl`, `has`, `any`, `all` | List operations       |
| `aiken/collection/dict` | `new`, `insert`, `get`, `has_key`                       | Dictionary operations |
| `aiken/hash`            | `blake2b_256`, `blake2b_224`, `sha2_256`                | Cryptographic hashing |
| `cardano/transaction`   | `OutputReference`, `Transaction`, `ScriptContext`       | Transaction types     |
| `cardano/assets`        | `lovelace_of`, `quantity_of`, `add`                     | Asset manipulation    |
| `cardano/address`       | `from_verification_key`, `from_script`                  | Address creation      |

---

### Validator Handler Signatures (Common Destructured Form)

```aiken
// Spending handler
spend(datum: Datum, redeemer: Redeemer, own_ref: OutputReference, tx: Transaction) -> Bool

// Minting handler
mint(redeemer: Redeemer, policy_id: PolicyId, tx: Transaction) -> Bool

// Staking reward withdrawal handler
withdraw(redeemer: Redeemer, credential: Credential, tx: Transaction) -> Bool

// Certificate publication handler
publish(redeemer: Redeemer, certificate: Certificate, tx: Transaction) -> Bool

// Fallback handler for other purposes
else(purpose: ScriptPurpose, tx: Transaction) -> Bool
```

---

### Built-in Operators

| Type           | Operators                        | Precedence | Example         |
| -------------- | -------------------------------- | ---------- | --------------- |
| **Pipeline**   | `\|>`                            | 0          | `x \|> f \|> g` |
| **Debugging**  | `?` (trace-if-false)             | 1          | `condition?`    |
| **Logical**    | `&&`, `\|\|`, `!`                | 1-3        | `a && b \|\| c` |
| **Comparison** | `==`, `!=`, `<`, `<=`, `>`, `>=` | 4          | `x >= 10`       |
| **Arithmetic** | `+`, `-`, `*`, `/`, `%`          | 4-6        | `10 + 5 * 2`    |

---

### Common Validation Patterns

```aiken
// Check for a required signature
list.has(tx.extra_signatories, required_signer)

// Check for a minimum ADA payment to an output
assets.lovelace_of(output.value) >= required_amount

// Check that a transaction is submitted before a deadline
when tx.validity_range.upper_bound is {
  Finite(upper) -> upper <= deadline
  _ -> False
}

// Check that a specific quantity of a token was minted
assets.quantity_of(tx.mint, policy_id, token_name) == expected_amount

// Find the continuing output to the same script address
list.find(tx.outputs, fn(out) { out.address == script_address })

// Assert a required datum structure
expect Some(MyDatum { field1, field2 }) = datum
```

---

### CLI Command Reference

```bash
# Project management
aiken new myproject/name      # Create a new project
aiken build                   # Compile the project
aiken fmt                     # Format all .ak files

# Testing and Benchmarking
aiken check                   # Type-check and run all tests
aiken check --match "test_name" # Run a specific test
aiken check --trace all       # Run tests with trace output
aiken bench                   # Run all benchmark tests

# Environments
aiken build --env mainnet     # Build using the mainnet environment config

# Documentation and Tooling
aiken docs                    # Generate HTML documentation for the project
aiken lsp                     # Start the Language Server Protocol for IDEs
```
