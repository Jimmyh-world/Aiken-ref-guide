# Glossary

## Overview

This document defines common terms used in Aiken and Cardano smart contract development.

---

- **Ada**: The native cryptocurrency of the Cardano blockchain.

- **Aiken**: A modern smart contract programming language and toolchain for Cardano that compiles to UPLC.

- **Blueprint**: A `plutus.json` file that describes your on-chain contract and its binary interface, following the CIP-0057 standard.

- **Datum**: Arbitrary data attached to a UTxO. Validators can read the datum of the UTxO they are validating to make decisions.

- **eUTxO (Extended UTxO)**: The accounting model used by Cardano. It extends Bitcoin's UTxO model by allowing UTxOs to carry arbitrary data (datums) and be locked by scripts (validators).

- **Handler**: A function within an Aiken `validator` block that responds to a specific script purpose (e.g., `spend`, `mint`).

- **Lovelace**: The smallest unit of Ada. 1 Ada = 1,000,000 Lovelaces.

- **Minting Policy**: A type of validator that controls the creation (minting) and destruction (burning) of native tokens.

- **Policy ID**: A 28-byte hash of a minting policy script. It serves as the unique identifier for a collection of tokens.

- **Redeemer**: User-provided data that accompanies a transaction when spending from a script address. It acts as an input or argument to the validator script.

- **Script Context**: A data structure provided to a validator at runtime that contains all information about the transaction being validated.

- **UPLC (Untyped Plutus Core)**: The low-level language that all Cardano smart contracts compile to. It is the language of the Cardano virtual machine.

- **UTxO (Unspent Transaction Output)**: The fundamental record of value on the Cardano blockchain. Each UTxO represents a specific amount of Ada and/or native tokens at a specific address.

- **Validator**: A script that locks UTxOs at a script address. It contains logic that must evaluate to `True` for a transaction to be allowed to spend those UTxOs.
