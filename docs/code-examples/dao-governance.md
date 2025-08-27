# DAO Governance Contract

## Overview

This example outlines a comprehensive DAO (Decentralized Autonomous Organization) governance contract. It manages a proposal lifecycle: creation, voting, and execution. This contract is a state machine where the proposal itself is the state.

## Key Concepts

- **Stateful Datum**: The `ProposalDatum` holds the entire state of a proposal, including vote counts and deadlines.
- **State Machine**: The `VoteRedeemer` defines the actions (`Vote`, `Execute`, `Cancel`) that transition the proposal's state.
- **On-Chain Voting**: The contract tallies votes directly on-chain by updating the datum of the proposal UTxO.
- **Time-Based Logic**: Voting and execution are constrained by deadlines stored in the datum.

## Code Example

### `validators/dao_governance.ak`

```aiken
use aiken/list
use cardano/transaction.{Output, Transaction}

// The datum holds the state of a single proposal.
type ProposalDatum {
  proposer: ByteArray,
  votes_for: Int,
  votes_against: Int,
  voting_deadline: Int,
  execution_deadline: Int,
  executed: Bool,
}

// The redeemer defines the actions that can be taken on a proposal.
type VoteRedeemer {
  Vote { voter_power: Int, in_favor: Bool }
  Execute
  Cancel
}

validator {
  spend(datum: ProposalDatum, redeemer: VoteRedeemer, context: ScriptContext) -> Bool {
    let tx = context.transaction

    when redeemer is {
      Vote { voter_power, in_favor } -> {
        // 1. Must happen before the voting deadline.
        let in_voting_period = is_before(tx, datum.voting_deadline)

        // 2. Voter power must be positive. (Signature/token ownership would be
        //    validated by another script consumed in the same transaction).
        let valid_power = voter_power > 0

        // 3. Calculate the new state of the proposal datum.
        let new_datum = if in_favor {
          ProposalDatum { ..datum, votes_for: datum.votes_for + voter_power }
        } else {
          ProposalDatum { ..datum, votes_against: datum.votes_against + voter_power }
        }

        // 4. Ensure the continuing output contains the updated datum.
        let state_updated = check_continuing_datum(tx.outputs, new_datum)

        and {
          in_voting_period,
          valid_power,
          state_updated,
        }
      }

      Execute -> {
        // 1. Must happen after voting ends but before execution deadline.
        let in_execution_period = and {
          is_after(tx, datum.voting_deadline),
          is_before(tx, datum.execution_deadline),
        }

        // 2. The proposal must not have been executed already.
        let not_executed = !datum.executed

        // 3. The proposal must have passed.
        let proposal_passed = datum.votes_for > datum.votes_against

        // 4. The continuing output must mark the proposal as executed.
        let new_datum = ProposalDatum { ..datum, executed: True }
        let state_updated = check_continuing_datum(tx.outputs, new_datum)

        and {
          in_execution_period,
          not_executed,
          proposal_passed,
          state_updated,
        }
      }

      Cancel -> {
        // Only the original proposer can cancel, and only before voting ends.
        and {
          list.has(tx.extra_signatories, datum.proposer),
          is_before(tx, datum.voting_deadline),
        }
      }
    }
  }
}

// Helper to check for the correct continuing datum.
fn check_continuing_datum(outputs: List<Output>, expected_datum: ProposalDatum) -> Bool {
  list.any(outputs, fn(output) {
    when output.datum is {
      InlineDatum(d) -> d == expected_datum
      _ -> False
    }
  })
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
```

## Security Considerations

- **Vote Validation**: This simplified example assumes `voter_power` is valid. A real DAO would require the `Vote` transaction to also spend a UTxO containing the voter's governance tokens or NFT, with another validator confirming the signature and token ownership.
- **Proposal Uniqueness**: The off-chain logic must ensure that each proposal UTxO is created with a unique identifier to prevent duplicates.
- **Execution Logic**: The `Execute` branch only validates the state transition. The transaction that executes a proposal would also need to include the actual operations (e.g., payments from a treasury) which would be validated by other scripts.

## Related Topics

- [State Machines](../patterns/state-machines.md)
- [Composability](../patterns/composability.md)
- [Multi-Signature Pattern](../patterns/multisig.md)

## References

- This example is a foundational pattern. Real-world DAOs often have more complex rules regarding quorums, vote delegation, and treasury management.
