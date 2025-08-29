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
  spend(datum: Option<PaymentDatum>, redeemer: PaymentRedeemer, _own_ref: OutputReference, self: Transaction) -> Bool {
    when datum is {
      Some(payment_datum) -> {
        // The redeemer could lie about the amount!
        check_payment_to(self, payment_datum.recipient, redeemer.amount)
      }
      None -> False
    }
  }

  else(_) {
    fail
  }
}

// GOOD: Validates against the datum, which is locked on-chain
validator secure_payment {
  spend(datum: Option<PaymentDatum>, _: Void, _own_ref: OutputReference, self: Transaction) -> Bool {
    when datum is {
      Some(payment_datum) -> {
        // The amount is from the trusted, on-chain datum.
        check_payment_to(self, payment_datum.recipient, payment_datum.amount)
      }
      None -> False
    }
  }

  else(_) {
    fail
  }
}
```

### Using Predictable "Randomness"

- **Anti-Pattern**: Using on-chain data like the transaction hash or validity interval as a source of randomness for a lottery or game.
- **Risk**: All on-chain data is deterministic and predictable by the user building the transaction. An attacker can repeatedly build transactions until they get a favorable "random" outcome before submitting.
- **Solution**: Use a commit-reveal scheme. This is a multi-transaction process where users first commit to a secret hash, and then reveal the secret in a later transaction. This prevents them from knowing the outcome in advance.

### Placeholder Security (False Confidence)

- **Anti-Pattern**: Using hardcoded `True` values or placeholder functions that appear to implement security but actually bypass all validation.
- **Risk**: Creates false confidence in tests and documentation while providing zero actual protection. Extremely dangerous for production deployment.
- **Solution**: Implement real validation logic or use circuit breakers to prevent accidental deployment.

```aiken
// BAD: Placeholder security that bypasses validation
validator dangerous_token {
  mint(redeemer: Action, _datum: Void, self: Transaction) -> Bool {
    // Placeholder admin check - ANYONE CAN MINT!
    let admin_signed = True  // ❌ CRITICAL SECURITY FLAW

    when redeemer is {
      Mint { amount } -> admin_signed && amount > 0
      Burn { amount } -> amount < 0
    }
  }
}

// GOOD: Real validation or safe circuit breaker
validator secure_token_or_circuit_breaker(admin_pkh: ByteArray) {
  mint(redeemer: Action, _datum: Void, self: Transaction) -> Bool {
    when redeemer is {
      Mint { amount } -> {
        // Real admin signature verification
        let admin_signed = list.has(self.extra_signatories, admin_pkh)
        and {
          admin_signed,
          amount > 0,
        }
      }
      // Alternative: Circuit breaker approach
      _ -> fail @"NOT PRODUCTION READY: Complete implementation required"
    }
  }

  else(_) {
    fail
  }
}
```

### Using Deprecated Aiken Patterns

- **Anti-Pattern**: Using outdated syntax like `context: ScriptContext` or accessing `context.purpose.policy_id` in modern Aiken.
- **Risk**: Code won't compile with current Aiken versions, or produces runtime errors.
- **Solution**: Use modern `self: Transaction` syntax and alternative approaches for policy ID access.

```aiken
// BAD: Deprecated patterns that won't work
validator outdated_nft(utxo_ref: OutputReference) {
  mint(redeemer: Void, context: ScriptContext) -> Bool {  // ❌ Deprecated
    let tx = context.transaction
    let policy_id = context.purpose.policy_id  // ❌ Not available

    list.any(tx.inputs, fn(input) {
      input.output_reference == utxo_ref
    })
  }
}

// GOOD: Modern Aiken patterns
validator modern_nft(utxo_ref: OutputReference) {
  mint(redeemer: NftAction, _datum: Void, self: Transaction) -> Bool {
    when redeemer is {
      Mint { token_name } -> {
        // Modern UTxO validation
        let utxo_consumed = list.any(self.inputs, fn(input) {
          input.output_reference == utxo_ref
        })

        // Modern quantity validation without policy_id access
        let minted_value = assets.without_lovelace(self.mint)
        let policy_dict = assets.to_dict(minted_value)
        let total_minted = policy_dict
          |> dict.foldl(0, fn(_policy_id, asset_dict, acc) {
              acc + dict.foldl(asset_dict, 0, fn(_asset_name, quantity, sum) {
                sum + quantity
              })
            })

        and {
          utxo_consumed,
          total_minted == 1,
          token_name != "",
        }
      }
      _ -> False
    }
  }

  else(_) {
    fail
  }
}
```

### Insufficient Testing Infrastructure

- **Anti-Pattern**: Writing tests that always pass due to placeholder helper functions, creating false confidence.
- **Risk**: Broken security logic appears to work correctly, leading to vulnerable production deployments.
- **Solution**: Write tests that actually exercise security logic and include negative test cases.

```aiken
// BAD: Test helper that always passes
pub fn admin_signed_INSECURE_PLACEHOLDER(_tx: ByteArray, _admin_pkh: ByteArray) -> Bool {
  True  // ❌ Provides false confidence in tests
}

test admin_authorization() {
  // This test will always pass but doesn't test anything real
  admin_signed_INSECURE_PLACEHOLDER(#"fake_tx", #"fake_admin")
}

// GOOD: Real testing with actual validation
use aiken/collection/list

pub fn admin_signed(signatories: List<ByteArray>, admin_pkh: ByteArray) -> Bool {
  list.has(signatories, admin_pkh)
}

test admin_authorization_success() {
  let valid_signatories = [#"admin_key", #"other_key"]
  let admin_key = #"admin_key"

  admin_signed(valid_signatories, admin_key)  // Should pass
}

test admin_authorization_failure() fail {
  let invalid_signatories = [#"wrong_key", #"other_key"]
  let admin_key = #"admin_key"

  admin_signed(invalid_signatories, admin_key)  // Should fail
}
```

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
