# Smart Contract Audit Checklist

## Overview

This document provides a comprehensive checklist for auditing Aiken smart contracts before deployment. It covers security, performance, and operational readiness at multiple levels.

## Key Concepts

- **Internal Audit**: A review conducted by the development team to catch issues early.
- **External Audit**: A formal review conducted by a professional third-party security firm.
- **Scope**: The audit should cover all on-chain code, off-chain integration code, and deployment scripts.
- **Severity**: Issues found should be classified by severity (e.g., Critical, High, Medium, Low, Informational).

---

## Smart Contract Level (On-Chain Code)

### Access Control

- [ ] Are ownership and administrative roles correctly implemented?
- [ ] Can administrative functions be accessed by unauthorized users?
- [ ] Does the contract correctly validate signatures for all privileged actions?

### State Transitions

- [ ] Is every possible state transition explicitly handled?
- [ ] Does the validator correctly check the continuing output's datum for every state change?
- [ ] Are terminal states truly terminal (i.e., no valid transitions out of them)?
- [ ] Is a nonce or other mechanism used to prevent state replay attacks?

### Input and Data Validation

- [ ] Are all inputs from datums and redeemers treated as untrusted?
- [ ] Is there any possibility of deserializing a `Data` object into an unexpected custom type?
- [ ] Are all numerical inputs (amounts, counts) checked for valid ranges (e.g., non-negative)?

### Common Vulnerabilities

- [ ] Is the contract vulnerable to Double Satisfaction attacks? (Is the Tagged Output Pattern used where necessary?)
- [ ] Is time handled correctly using transaction validity intervals? (No unbounded intervals for deadlines).
- [ ] Is integer arithmetic safe? (Aiken's `Int` prevents overflows, but logic errors are still possible).

### Logic and Economics

- [ ] Does the contract logic correctly implement the intended business rules?
- [ ] Can the contract's economic incentives be manipulated (e.g., oracle manipulation, flash loans)?
- [ ] Does the contract correctly preserve value (i.e., value in equals value out, plus fees)?

---

## Transaction Level (Interaction)

- [ ] Are all inputs and outputs of a transaction properly accounted for?
- [ ] Can an attacker introduce unexpected inputs or outputs to exploit the validator?
- [ ] Are fees handled correctly?
- [ ] Are token minting/burning values correctly checked in the transaction's `mint` field?

---

## System Level (Off-Chain and Operational)

### Off-Chain Code

- [ ] Does the off-chain transaction-building code correctly match the on-chain validation logic?
- [ ] Is user input sanitized correctly before being used to build transactions?
- [ ] Does the application handle blockchain rollbacks gracefully?

### Testing and Documentation

- [ ] Is test coverage high, including all critical paths and failure cases?
- [ ] Are property-based tests used to check for core invariants?
- [ ] Is the codebase well-documented and easy for an auditor to understand?

### Deployment and Operations

- [ ] Are contract parameters (e.g., admin keys, fees) correct for the target environment (testnet/mainnet)?
- [ ] Is there an emergency plan in case a vulnerability is discovered post-deployment?
- [ ] Are monitoring systems in place to track contract health and activity?

## Related Topics

- [Security Overview](./overview.md)
- [Validator Risks](./validator-risks.md)
- [Deployment](../integration/deployment.md)

## References

- [Leading Security Audit Firms in Cardano Ecosystem](https://cardano.org/partners/?category=audit-and-security)
