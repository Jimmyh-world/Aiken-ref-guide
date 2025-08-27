# Aiken Anti-Patterns

## Overview

Anti-patterns are common solutions to problems that are ineffective and carry a high risk of introducing bugs or security vulnerabilities. This guide identifies common anti-patterns in Aiken development and provides better alternatives.

## Security Anti-Patterns

### Trusting Off-Chain Data

- **Anti-Pattern**: The validator trusts that data in the datum or redeemer is accurate without verifying it against the transaction context.
- **Risk**: An attacker can provide a valid-looking datum/redeemer that tricks the validator into authorizing a malicious transaction.
- **Solution**: Always treat the datum and redeemer as user input. Verify all critical data points against the transaction context (inputs, outputs, signatories, etc.).

```aiken
// BAD: Trusts the redeemer to state the correct amount
validator vulnerable_payment {
  spend(datum: PaymentDatum, redeemer: PaymentRedeemer, context: ScriptContext) -> Bool {
    // The redeemer could lie about the amount!
    check_payment_to(context.transaction, datum.recipient, redeemer.amount)
  }
}

// GOOD: Validates against the datum, which is locked on-chain
validator secure_payment {
  spend(datum: PaymentDatum, _: Void, context: ScriptContext) -> Bool {
    // The amount is from the trusted, on-chain datum.
    check_payment_to(context.transaction, datum.recipient, datum.amount)
  }
}
```

### Using Predictable "Randomness"

- **Anti-Pattern**: Using on-chain data like the transaction hash or validity interval as a source of randomness for a lottery or game.
- **Risk**: All on-chain data is deterministic and predictable by the user building the transaction. An attacker can repeatedly build transactions until they get a favorable "random" outcome before submitting.
- **Solution**: Use a commit-reveal scheme. This is a multi-transaction process where users first commit to a secret hash, and then reveal the secret in a later transaction. This prevents them from knowing the outcome in advance.

## Performance Anti-Patterns

### Multiple List Traversals

- **Anti-Pattern**: Performing multiple separate operations on the same list, causing it to be traversed multiple times.
- **Risk**: High execution costs (CPU), especially for large lists.
- **Solution**: Combine operations into a single `fold` or use tail-recursive helper functions to process the list in a single pass.

```aiken
// BAD: Traverses the list three times
fn inefficient_check(items: List<Item>) -> Bool {
  let has_items = !list.is_empty(items)
  let all_valid = list.all(items, fn(item) { item.amount > 0 })
  let total = list.foldl(items, 0, fn(acc, item) { acc + item.amount })
  has_items && all_valid && total < 1000
}

// GOOD: Traverses the list only once
fn efficient_check(items: List<Item>) -> Bool {
  check_helper(items, 0)
}
fn check_helper(items: List<Item>, current_total: Int) -> Bool {
  when items is {
    [] -> current_total > 0 && current_total < 1000
    [head, ..tail] ->
      if head.amount > 0 {
        check_helper(tail, current_total + head.amount)
      } else {
        False
      }
  }
}
```

## Related Topics

- [Validator Risks](./validator-risks.md)
- [Performance Optimization](../performance/optimization.md)
- [Security Overview](./overview.md)

## References

- [Aiken Documentation: Common Pitfalls](https://aiken-lang.org/common-pitfalls)
