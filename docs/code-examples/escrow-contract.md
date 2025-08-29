# Escrow Contract

## Overview

This example implements a secure escrow contract in Aiken. It allows a buyer to deposit funds that can either be released to a seller upon the buyer's approval, or refunded to the buyer if a deadline passes or both parties agree to cancel.

## Key Concepts

- **State Machine**: The contract implicitly follows a state machine (Locked -> Released/Refunded).
- **Roles**: The datum defines the roles of `buyer` and `seller`.
- **Time-based Logic**: A `deadline` is used to allow for automatic refunds.
- **Multi-Signature for Cancellation**: Both parties can sign to cancel the escrow before the deadline.

## Code Example

### `validators/escrow.ak`

```aiken
use aiken/collection/list
use cardano/transaction.{Transaction, OutputReference, Output}
use cardano/address.{VerificationKey}
use cardano/assets.{ada_policy_id, ada_asset_name, quantity_of}
use aiken/interval.{Finite}

// The datum holds all the parameters of the escrow agreement.
type EscrowDatum {
  buyer: ByteArray,
  seller: ByteArray,
  price: Int,
  deadline: Int, // A POSIX timestamp
}

// The redeemer defines the possible actions to resolve the escrow.
type EscrowAction {
  Complete
  Cancel
}

validator escrow_contract {
  spend(datum: Option<EscrowDatum>, action: EscrowAction, _own_ref: OutputReference, self: Transaction) -> Bool {
    when datum is {
      Some(escrow_datum) -> {
        when action is {
          // The 'Complete' action releases funds to the seller.
          Complete -> {
            // 1. Must be signed by the buyer.
            let buyer_signed = list.has(self.extra_signatories, escrow_datum.buyer)

            // 2. The seller must be paid the correct price.
            let seller_paid = check_payment_to(self.outputs, escrow_datum.seller, escrow_datum.price)

            // 3. Must happen before the deadline.
            let before_deadline = is_before(self, escrow_datum.deadline)

            and {
              buyer_signed,
              seller_paid,
              before_deadline,
            }
          }

          // The 'Cancel' action refunds the funds.
          Cancel -> {
            // Cancellation is allowed under two conditions:
            // 1. The deadline has passed.
            let deadline_passed = is_after(self, escrow_datum.deadline)

            // 2. Both buyer and seller agree to cancel.
            let both_signed = and {
              list.has(self.extra_signatories, escrow_datum.buyer),
              list.has(self.extra_signatories, escrow_datum.seller),
            }

            // Either condition is sufficient.
            or {
              deadline_passed,
              both_signed,
            }
          }
        }
      }
      None -> False
    }
  }
}

// Helper function to check if seller receives payment
fn check_payment_to(outputs: List<Output>, recipient: ByteArray, min_amount: Int) -> Bool {
  list.any(outputs, fn(output) {
    when output.address.payment_credential is {
      VerificationKey(hash) -> {
        let ada_amount = quantity_of(output.value, ada_policy_id, ada_asset_name)
        hash == recipient && ada_amount >= min_amount
      }
      _ -> False
    }
  })
}

// Helper function to check if transaction is before deadline
fn is_before(self: Transaction, deadline: Int) -> Bool {
  when self.validity_range.upper_bound is {
    Finite(upper) -> upper <= deadline
    _ -> False
  }
}

// Helper function to check if transaction is after deadline
fn is_after(self: Transaction, deadline: Int) -> Bool {
  when self.validity_range.lower_bound is {
    Finite(lower) -> lower >= deadline
    _ -> False
  }
}
```

### `aiken.toml`

```toml
name = "my-project/escrow-contract"
version = "1.0.0"
license = "MIT"
plutus_version = "v2"

[[dependencies]]
name = "aiken-lang/stdlib"
version = "2.1.0"
source = "github"
```

## Security Considerations

- **Exact Payment**: The `check_payment_to` helper uses `>=`. For stricter security, you might want to check for the exact amount (`==`) to prevent overpayment or other transaction manipulation.
- **Datum Injection**: The off-chain code that creates the escrow UTxO must ensure the `EscrowDatum` is correct. The on-chain code can only validate what it is given.
- **No Partial Payments**: This simple example does not handle partial payments or complex dispute resolution, which would require a more advanced state machine.

## Related Topics

- [State Machines](../patterns/state-machines.md)
- [Multi-Signature Pattern](../patterns/multisig.md)
- [Validator Risks](../security/validator-risks.md)

## References

- This example is a common smart contract pattern. For production use, consider adding features like dispute resolution with an arbiter.
