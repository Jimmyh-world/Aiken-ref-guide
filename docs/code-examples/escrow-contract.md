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
use aiken/list
use cardano/address.{Address}
use cardano/transaction.{Output}

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

validator {
  spend(datum: EscrowDatum, action: EscrowAction, context: ScriptContext) -> Bool {
    let tx = context.transaction

    when action is {
      // The 'Complete' action releases funds to the seller.
      Complete -> {
        // 1. Must be signed by the buyer.
        let buyer_signed = list.has(tx.extra_signatories, datum.buyer)

        // 2. The seller must be paid the correct price.
        let seller_address = address.from_verification_key(datum.seller, None)
        let seller_paid =
          check_payment_to(tx.outputs, seller_address, datum.price)

        // 3. Must happen before the deadline.
        let before_deadline = is_before(tx, datum.deadline)

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
        let deadline_passed = is_after(tx, datum.deadline)

        // 2. Both buyer and seller agree to cancel.
        let both_signed = and {
          list.has(tx.extra_signatories, datum.buyer),
          list.has(tx.extra_signatories, datum.seller),
        }

        // Either condition is sufficient.
        or {
          deadline_passed,
          both_signed,
        }
      }
    }
  }
}

// Helper to check if the transaction is submitted before a time.
fn is_before(tx: Transaction, time: Int) -> Bool {
  when tx.validity_range.upper_bound is {
    Finite(upper) -> upper <= time
    _ -> False
  }
}

// Helper to check if the transaction is submitted after a time.
fn is_after(tx: Transaction, time: Int) -> Bool {
  when tx.validity_range.lower_bound is {
    Finite(lower) -> lower > time
    _ -> False
  }
}

// Helper to check for a minimum payment to an address.
fn check_payment_to(outputs: List<Output>, recipient: Address, amount: Int) -> Bool {
  outputs
    |> list.any(fn(output) {
      output.address == recipient && assets.lovelace_of(output.value) >= amount
    })
}
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
