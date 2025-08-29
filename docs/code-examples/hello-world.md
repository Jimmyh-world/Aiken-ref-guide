# Hello World Validator

## Overview

This example demonstrates a basic "Hello World" spending validator in Aiken. It locks a UTxO that can only be spent if two conditions are met: the redeemer message is "Hello, World!" and the transaction is signed by the owner specified in the datum.

## Key Concepts

- **Datum**: Stores the owner's public key hash.
- **Redeemer**: Carries the message that must be validated.
- **`Transaction`**: Used to access the transaction's signatories and validation data.
- **Combined Logic**: Uses an `and` block to ensure multiple conditions are met.

## Code Example

### `lib/hello_world/types.ak`

```aiken
// Custom types for type-safe validation
pub type HelloWorldDatum {
  owner: ByteArray,
}

pub type HelloWorldRedeemer {
  message: ByteArray,
}
```

### `validators/hello_world.ak`

```aiken
// Production-Grade Hello World Validator
// Demonstrates modern Aiken patterns with secure transaction validation

use aiken/collection/list
use cardano/transaction.{OutputReference, Transaction}
use hello_world/types.{HelloWorldDatum, HelloWorldRedeemer}

// Hello World validator - demonstrates basic eUTxO model with security
validator hello_world {
  spend(
    datum: Option<HelloWorldDatum>,
    redeemer: HelloWorldRedeemer,
    _own_ref: OutputReference,
    self: Transaction,
  ) {
    when datum is {
      Some(hello_datum) -> {
        // 1. Message validation - must be exact match
        let valid_message = redeemer.message == "Hello, World!"
        
        // 2. Signature validation - owner must sign transaction
        let owner_signed = list.has(self.extra_signatories, hello_datum.owner)
        
        // 3. Security checks - prevent common attacks
        and {
          valid_message,                    // Correct message required
          owner_signed,                     // Owner signature required
          hello_datum.owner != "",          // Non-empty owner required
        }
      }
      None -> False  // Datum required
    }
  }

  else(_) {
    fail
  }
}
```

### `lib/hello_world/hello_world_test.ak`

```aiken
use aiken/list
use hello_world/hello_world.{spend}

// A helper function to create a mock ScriptContext for testing.
fn mock_context(signatories: List<ByteArray>) -> ScriptContext {
  // In a real test suite, you would build a more complete mock transaction.
  ScriptContext {
    transaction: Transaction {
      extra_signatories: signatories,
      // ... other fields would be mocked here
    },
    purpose: Spending(some_output_ref),
  }
}

// Test the success case.
test spend_succeeds() {
  let owner_key = #"00010203"
  let datum = Datum { owner: owner_key }
  let redeemer = "Hello, World!"
  let context = mock_context([owner_key])

  spend(datum, redeemer, context)
}

// Test the failure case where the signature is missing.
test spend_fails_without_signature() fail {
  let owner_key = #"00010203"
  let datum = Datum { owner: owner_key }
  let redeemer = "Hello, World!"
  let context = mock_context([]) // No signatories

  spend(datum, redeemer, context)
}

// Test the failure case where the message is wrong.
test spend_fails_with_wrong_message() fail {
  let owner_key = #"00010203"
  let datum = Datum { owner: owner_key }
  let redeemer = "Goodbye, World!" // Wrong message
  let context = mock_context([owner_key])

  spend(datum, redeemer, context)
}
```

## Related Topics

- [Validators](../language/validators.md)
- [Testing](../language/testing.md)
- [Data Structures](../language/data-structures.md)

## References

- [Aiken Language Tour: Hello World](https://aiken-lang.org/example--hello-world/basics)

