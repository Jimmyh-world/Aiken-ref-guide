# Common Validator Risks

## Overview

This document details common vulnerabilities found in Cardano smart contracts and provides secure patterns in Aiken to mitigate them.

## Double Satisfaction Attack

- **Risk Name**: Double Satisfaction
- **Description**: This vulnerability occurs when a validator's logic can be satisfied once but is used to justify multiple actions in a single transaction. This happens when the validation logic doesn't create a strict one-to-one link between the input being spent and the corresponding output.
- **Attack Scenarios**: An attacker could spend two UTxOs from a DEX contract but only provide payment for one, by crafting a transaction where the single payment output satisfies the validator for both inputs.
- **Mitigation Strategy**: Use the **Tagged Output Pattern**. Each continuing output's datum must be "tagged" with the unique `OutputReference` of the input it corresponds to. This enforces a one-to-one mapping.

### Code Example

```aiken
use aiken/collection/list
use cardano/transaction.{Transaction, OutputReference, Output}
use cardano/address.{VerificationKey}
use cardano/assets.{ada_policy_id, ada_asset_name, quantity_of}

// VULNERABLE: Checks for a valid payment but doesn't link it to a specific input.
validator vulnerable_swap {
  spend(datum: Option<SwapDatum>, _, _own_ref: OutputReference, self: Transaction) -> Bool {
    when datum is {
      Some(swap_datum) -> {
        // This check is ambiguous if multiple inputs from this script are spent.
        check_payment_to(self.outputs, swap_datum.seller, swap_datum.price)
      }
      None -> False
    }
  }
}

// SECURE: Uses the Tagged Output Pattern with modern Transaction syntax.
validator secure_swap {
  spend(datum: Option<SwapDatum>, _, own_ref: OutputReference, self: Transaction) -> Bool {
    when datum is {
      Some(swap_datum) -> {
        // Find the single output tagged with this input's OutputReference.
        let tagged_output = find_tagged_output(self.outputs, own_ref)
        // Perform validation only on that specific output.
        validate_payment_from_tagged(tagged_output, swap_datum.seller, swap_datum.price)
      }
      None -> False
    }
  }
}

// Helper function for payment validation
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
```

## Replay Attacks

- **Risk Name**: Replay Attack
- **Description**: In a stateful contract, a replay attack occurs when an attacker can reuse a previous redeemer or state to trigger an action that should only happen once.
- **Attack Scenarios**: An attacker could replay a "withdraw" action if the contract doesn't correctly invalidate or consume the state that permitted the first withdrawal.
- **Mitigation Strategy**: Use a **nonce** or a unique identifier in the datum. Each time the state is updated, the validator must ensure the nonce in the continuing output's datum is incremented. This makes each state unique and prevents replays.

### Code Example

```aiken
use aiken/collection/list
use cardano/transaction.{Transaction, OutputReference, Output}

validator anti_replay_state_machine {
  spend(datum: Option<StateDatum>, _, _own_ref: OutputReference, self: Transaction) -> Bool {
    when datum is {
      Some(state_datum) -> {
        // Find the continuing output going back to the script address.
        when find_continuing_output(self.outputs) is {
          Some(continuing_output) -> {
            when continuing_output.datum is {
              InlineDatum(new_datum) -> {
                // The core check: ensure the nonce is strictly increasing.
                new_datum.nonce == state_datum.nonce + 1
              }
              _ -> False
            }
          }
          None -> False
        }
      }
      None -> False
    }
  }
}
```

## Time-based Attacks

- **Risk Name**: Invalid Time Range Exploitation
- **Description**: Cardano does not have a concept of "current time" on-chain. Time is expressed as a validity interval in the transaction. Logic that incorrectly handles this interval can be exploited.
- **Attack Scenarios**: A vesting contract might release funds early if the validator only checks `now < deadline` without considering that the transaction's validity range could be infinitely long.
- **Mitigation Strategy**: Always validate against the transaction's `validity_range`. For deadlines, check the `upper_bound`. For time-locks, check the `lower_bound`.

### Code Example

```aiken
use aiken/interval.{Finite}
use cardano/transaction.{Transaction, OutputReference}

validator time_locked_vesting {
  spend(datum: Option<VestingDatum>, _, _own_ref: OutputReference, self: Transaction) -> Bool {
    when datum is {
      Some(vesting_datum) -> {
        let tx_range = self.validity_range
        
        // To unlock, the transaction's validity must START AFTER the unlock time.
        when tx_range.lower_bound is {
          Finite(lower_time) -> lower_time >= vesting_datum.unlock_time
          _ -> False // Infinite lower bound is invalid
        }
      }
      None -> False
    }
  }
}
```

## Related Topics

- [Tagged Output Pattern](../patterns/tagged-output.md)
- [State Machines](../patterns/state-machines.md)
- [Anti-patterns](./anti-patterns.md)

## References

- [Aiken Security: Double Satisfaction](https://aiken-lang.org/security-considerations/double-satisfaction)
