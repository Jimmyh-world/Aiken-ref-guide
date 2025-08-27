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
// VULNERABLE: Checks for a valid payment but doesn't link it to a specific input.
validator vulnerable_swap {
  spend(datum: SwapDatum, _, context: ScriptContext) -> Bool {
    // This check is ambiguous if multiple inputs from this script are spent.
    check_payment_to(context.transaction, datum.seller, datum.price)
  }
}

// SECURE: Uses the Tagged Output Pattern.
validator secure_swap {
  spend(datum: SwapDatum, _, own_ref: OutputReference, context: ScriptContext) -> Bool {
    // Find the single output tagged with this input's OutputReference.
    let tagged_output = find_tagged_output(context.transaction.outputs, own_ref)
    // Perform validation only on that specific output.
    validate_payment_from_tagged(tagged_output, datum.seller, datum.price)
  }
}
```

## Replay Attacks

- **Risk Name**: Replay Attack
- **Description**: In a stateful contract, a replay attack occurs when an attacker can reuse a previous redeemer or state to trigger an action that should only happen once.
- **Attack Scenarios**: An attacker could replay a "withdraw" action if the contract doesn't correctly invalidate or consume the state that permitted the first withdrawal.
- **Mitigation Strategy**: Use a **nonce** or a unique identifier in the datum. Each time the state is updated, the validator must ensure the nonce in the continuing output's datum is incremented. This makes each state unique and prevents replays.

### Code Example

```aiken
validator anti_replay_state_machine {
  spend(datum: StateDatum, _, context: ScriptContext) -> Bool {
    // Find the continuing output going back to the script address.
    expect Some(continuing_output) = find_continuing_output(context.transaction)
    expect InlineDatum(new_datum: StateDatum) = continuing_output.datum

    // The core check: ensure the nonce is strictly increasing.
    new_datum.nonce == datum.nonce + 1
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
validator time_locked_vesting {
  spend(datum: VestingDatum, _, context: ScriptContext) -> Bool {
    let tx_range = context.transaction.validity_range

    // To unlock, the transaction's validity must START AFTER the unlock time.
    when tx_range.lower_bound is {
      Finite(lower_time) -> lower_time >= datum.unlock_time
      _ -> False // Infinite lower bound is invalid
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
