# Aiken Syntax

## Overview

This document covers the fundamental syntax of the Aiken language, including variables, constants, functions, and types. Aiken's syntax is designed to be clean, readable, and expressive.

## Key Concepts

- **Immutability**: All variable bindings in Aiken are immutable.
- **Type Inference**: The compiler can infer most types, making explicit annotations optional.
- **Expressions**: Almost everything in Aiken is an expression that returns a value.
- **Pipelining**: The `|>` operator allows for chaining function calls in a readable way.
- **Comments**: Aiken supports single-line comments starting with `//`.

## Variables and Constants

```aiken
// Immutable bindings
let age = 25

// Pattern matching assignment
let (x, y) = (10, 20)

// Constants (compile-time)
const max_supply = 1_000_000

// Type annotations (optional)
let count: Int = 10
let message: ByteArray = "Hello"
```

## Functions

```aiken
// Named function
fn add(x: Int, y: Int) -> Int {
  x + y
}

// Anonymous function (lambda)
let multiply = fn(a, b) { a * b }

// Generic function
fn identity(x: a) -> a {
  x
}

// Labeled arguments
fn replace(self: String, pattern: String, replacement: String) {
  // implementation
}
// Call with labels in any order
replace(pattern: ",", replacement: " ", self: "A,B,C")

// Pipe operator for readable function composition
let result =
  input
    |> validate
    |> transform
    |> save
```

## Primitive Types

- **`Bool`**: `True` or `False`.
- **`Int`**: An arbitrary-precision integer.
- **`ByteArray`**: A sequence of bytes, used for hashes, keys, and raw data. Can be defined with `#"..."` for hex or `"..."` for UTF-8.
- **`String`**: A UTF-8 encoded string, primarily for error messages and comments. Not usable for on-chain logic.
- **`Void`**: The unit type, representing the absence of a value.

## Imports and Module System

Modern Aiken development requires importing the standard library for transaction validation and list operations.

### Essential Imports for Validators
```aiken
// Core transaction types and operations
use cardano/transaction.{Transaction, OutputReference, Output}

// List operations (required for checking signatories, outputs, etc.)
use aiken/collection/list

// Address types for payment validation
use cardano/address.{VerificationKey}

// Asset operations for checking ADA amounts
use cardano/assets.{ada_policy_id, ada_asset_name, quantity_of}

// Interval types for time validation
use aiken/interval.{IntervalBound, Finite}
```

### Project Configuration
Every Aiken project must include the standard library dependency in `aiken.toml`:

```toml
[[dependencies]]
name = "aiken-lang/stdlib"
version = "2.1.0"
source = "github"
```

### Common Import Patterns
```aiken
// Import specific functions
use aiken/collection/list.{has, any, filter}

// Import types with custom alias
use cardano/transaction.{Transaction as Tx}

// Import everything from a module (use sparingly)
use aiken/collection/list

// Import with module prefix
use aiken/collection/list as List
// Usage: List.has(my_list, element)
```

## Security Considerations

- **Integer Overflows**: Aiken's `Int` type has arbitrary precision, which prevents traditional integer overflow and underflow vulnerabilities.
- **Type Safety**: Use specific custom types instead of generic `Data` where possible to leverage the type system for stronger validation.

## Related Topics

- [Data Structures](./data-structures.md)
- [Control Flow](./control-flow.md)
- [Modules](./modules.md)

## References

- [Aiken Language Tour: Basics](https://aiken-lang.org/language-tour/basics)
