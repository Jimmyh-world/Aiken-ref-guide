# State Machine Pattern

## Overview

The State Machine pattern is a powerful way to model smart contracts that have a distinct lifecycle with different states and transitions. It ensures that the contract can only move from one state to another through predefined, valid transitions.

## Problem Solved

This pattern manages the complexity of contracts that evolve over time. It prevents invalid operations by enforcing a strict set of rules for how the contract's state (represented by its datum) can change.

## When to Use

- **Escrow Contracts**: States like `Locked`, `Released`, `Refunded`.
- **Governance Proposals**: States like `Voting`, `Accepted`, `Executed`.
- **Auctions or Games**: Any multi-step process with distinct phases.

## Implementation

The implementation involves a `State` type (in the datum), an `Action` type (in the redeemer), and a validator that uses pattern matching to control transitions.

```aiken
// State of the contract, stored in the datum
type GameState {
  Waiting
  InProgress { players: List<ByteArray>, current_turn: ByteArray }
  Finished { winner: ByteArray }
}

// Actions to change the state, provided in the redeemer
type GameAction {
  Start { players: List<ByteArray> }
  Move { player: ByteArray, move_data: Data }
  End
}

validator game_contract {
  spend(current_state: GameState, action: GameAction, context: ScriptContext) -> Bool {
    when (current_state, action) is {
      // Transition from Waiting to InProgress
      (Waiting, Start { players }) -> {
        validate_start_conditions(context.transaction, players)
      }

      // Stay in InProgress state while making a move
      (InProgress { current_turn, .. }, Move { player, .. }) -> {
        and {
          player == current_turn,
          validate_move(context.transaction),
        }
      }

      // Transition from InProgress to Finished
      (InProgress { .. }, End) -> {
        validate_end_conditions(context.transaction)
      }

      // Any other combination is an invalid transition
      _ -> False
    }
  }
}
```

## Security Considerations

- **State Transition Validation**: The most critical aspect is ensuring that for every valid transition, the validator checks that the _continuing output_ contains the correct new state in its datum. Without this, an attacker could transition the state incorrectly.
- **Terminal States**: Ensure that terminal states (like `Finished`) cannot be transitioned out of.
- **Exhaustive Matching**: Use a `_ -> False` catch-all case to explicitly fail on invalid combinations of states and actions.

## Related Topics

- [Control Flow](../language/control-flow.md)
- [Data Structures](../language/data-structures.md)
- [Escrow Contract Example](../code-examples/escrow-contract.md)

## References

- [Aiken Documentation: State Machines](https://aiken-lang.org/fundamentals/common-design-patterns#state-machines)
