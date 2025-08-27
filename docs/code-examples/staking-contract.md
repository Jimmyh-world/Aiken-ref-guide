# Staking Contract (Conceptual)

## Overview

This document provides a conceptual outline and simplified code example for a staking contract in Aiken. A real staking contract would be significantly more complex, likely involving state management for rewards distribution, lockup periods, and withdrawal logic.

**Note**: This is a simplified example for educational purposes. Production staking contracts require rigorous security auditing.

## Key Concepts

- **Staking Datum**: Stores information about a user's stake, such as the owner and the amount staked.
- **State Management**: The contract must track each user's stake and potential rewards. This often involves a state machine pattern.
- **Time-locks**: Staking often involves lockup periods, requiring careful handling of transaction validity intervals.
- **Rewards Distribution**: A mechanism (often off-chain or via a second script) is needed to calculate and distribute rewards.

## Simplified Code Example

This example focuses only on the "Stake" and "Unstake" logic. It does not include rewards calculation.

### `validators/staking.ak`

```aiken
use aiken/list
use cardano/address.{Address}
use cardano/transaction.{Output}

// The datum for each staked UTxO.
type StakeDatum {
  owner: ByteArray,
  staked_amount: Int,
}

// The actions a user can take.
type Action {
  Unstake
}

// The validator is parameterized with the address of the treasury
// where staking rewards are generated.
validator(treasury_address: Address) {
  spend(datum: StakeDatum, redeemer: Action, context: ScriptContext) -> Bool {
    let tx = context.transaction

    when redeemer is {
      Unstake -> {
        // 1. The owner must sign the transaction to unstake.
        let owner_signed = list.has(tx.extra_signatories, datum.owner)

        // 2. The staked amount must be returned to the owner.
        // This is a simplified check; a real contract would need to find
        // the specific output going to the owner.
        let owner_address = address.from_verification_key(datum.owner, None)
        let owner_paid_back =
          check_payment_to(tx.outputs, owner_address, datum.staked_amount)

        and {
          owner_signed,
          owner_paid_back,
        }
      }
    }
  }
}

// Helper function to check for payment to an address.
fn check_payment_to(outputs: List<Output>, recipient: Address, amount: Int) -> Bool {
  outputs
    |> list.any(fn(output) {
      output.address == recipient && assets.lovelace_of(output.value) >= amount
    })
}
```

### How Staking (Depositing) Works

To stake, a user sends a transaction that creates a new UTxO at the script address. This transaction is not validated by the `spend` handler. The UTxO's datum would contain the `StakeDatum` with the user's public key hash and the amount they are staking.

## Security Considerations

- **Rewards Calculation**: The logic for calculating and distributing rewards is the most complex and vulnerable part of a staking contract. This often requires a trusted off-chain component or a sophisticated on-chain state machine.
- **State Management**: The contract must be secure against replay attacks (e.g., a user unstaking multiple times). Using a nonce in the datum is essential.
- **Batching**: To avoid concurrency issues, production contracts often use batching patterns where multiple users' stakes are handled in a single UTxO.

## Related Topics

- [State Machines](../patterns/state-machines.md)
- [DAO Governance](./dao-governance.md)
- [Security Overview](../security/overview.md)

## References

- This is a conceptual example. For production systems, refer to audited open-source staking contracts in the Cardano ecosystem.
