# Introduction to Aiken

## Overview

Aiken is a modern, functional programming language and toolchain for developing smart contracts on the Cardano blockchain. It is geared towards robustness, safety, and an excellent developer experience, compiling directly to Untyped Plutus Core (UPLC).

## Key Concepts

- **Purpose-Built**: Designed specifically for creating on-chain validator scripts for Cardano.
- **Modern Syntax**: Inspired by Rust, Gleam, and Elm, making it more accessible than Haskell-based Plutus.
- **Developer-Centric**: Features fast compilation, clear error messages, and a zero-configuration toolchain.
- **Market Leader**: As of 2024, Aiken is used in approximately 62% of Cardano smart contract activity.
- **Performance**: Aiken contracts are highly efficient. For example, SundaeSwap V3 saw a 2016.7% performance increase over its V1 contracts.

## Why Choose Aiken?

### Developer Experience

Aiken prioritizes a smooth workflow with a built-in code formatter, testing framework, and Language Server Protocol (LSP). This focus reduces the setup and debugging time often associated with smart contract development.

### Safety and Security

As a language designed for financial applications, Aiken's feature set is focused on writing secure and auditable on-chain code. Its strong type system and functional paradigm help prevent common bugs and vulnerabilities.

### Why Aiken Over Haskell Plutus

- **Simpler Setup**: Avoids the complex Haskell environment and PlutusTx compiler plugin setup.
- **Faster Compilation**: Compiles in seconds, compared to minutes for many Plutus projects.
- **Better Tooling**: Provides clearer error messages and a more integrated development environment.

## Related Topics

- [Getting Started](./getting-started.md)
- [Aiken Ecosystem](./ecosystem.md)
- [Language Syntax](../language/syntax.md)

## References

- [Official Aiken Website](https://aiken-lang.org/)
- [Aiken Language Tour](https://aiken-lang.org/language-tour)
