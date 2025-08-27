# Reusability Patterns

## Overview

This document outlines patterns for creating modular, reusable, and maintainable smart contract components in Aiken. Following these patterns leads to cleaner, safer, and more auditable code.

## Problem Solved

These patterns address the challenge of managing complexity in large smart contract systems by promoting code reuse and clear separation of concerns.

## DRY (Don't Repeat Yourself)

Avoid duplicating code by abstracting common logic into helper functions within a shared module. This is especially useful for validation logic.

### Example: A Common Validation Library

```aiken
// In lib/my_project/validation.ak

// Validate that a transaction is signed by a specific owner
pub fn is_signed_by(owner: ByteArray, context: ScriptContext) -> Bool {
  list.has(context.transaction.extra_signatories, owner)
}

// Validate that a transaction occurs before a deadline
pub fn before_deadline(deadline: Int, context: ScriptContext) -> Bool {
  when context.transaction.validity_range.upper_bound is {
    Finite(upper) -> upper <= deadline
    _ -> False // A transaction with no upper bound is invalid for a deadline
  }
}
```

This library can then be imported and used across multiple validators.

## Single Responsibility Principle (SRP)

Each module and validator should have a single, well-defined responsibility. Avoid creating monolithic validators that handle many different, unrelated tasks.

### Example: Separating Concerns

```aiken
// Instead of one giant validator, use focused modules
use my_project/validation.{is_signed_by}
use my_project/state.{calculate_new_state}
use my_project/payments.{check_payment_to}

validator focused_contract {
  spend(datum: MyDatum, redeemer: Action, context: ScriptContext) -> Bool {
    and {
      // Responsibility 1: Authentication (from validation module)
      is_signed_by(datum.owner, context),

      // Responsibility 2: Payment validation (from payments module)
      check_payment_to(context.transaction, datum.seller, datum.price),

      // Responsibility 3: State transition (from state module)
      calculate_new_state(datum, redeemer) == find_continuing_datum(context),
    }
  }
}
```

## Security Considerations

- **Thorough Testing of Shared Code**: Reusable modules are critical infrastructure. They must have 100% test coverage, including property-based tests for core invariants.
- **Clear API Contracts**: Public functions in shared modules should have clear documentation explaining their assumptions and expected behavior.
- **Avoid Tight Coupling**: Design modules to be as independent as possible to prevent changes in one module from having unintended side effects in another.

## Related Topics

- [Modules](../language/modules.md)
- [Composability](./composability.md)
- [Audit Checklist](../security/audit-checklist.md)

## References

- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)
