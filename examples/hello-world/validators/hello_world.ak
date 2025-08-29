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
          valid_message,
          // Correct message required
          owner_signed,
          // Owner signature required
          hello_datum.owner != "",
          // Non-empty owner
          redeemer.message != "",
        }
      }
      // Non-empty message
      None -> False
    }
    // Datum required
  }

  else(_) {
    fail
  }
}
