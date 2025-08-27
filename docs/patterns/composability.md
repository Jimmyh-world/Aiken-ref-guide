# Composability Patterns

## Overview

Composability is the ability to combine smaller, independent smart contract components to create more complex systems. In Aiken, this is typically achieved by having validators that interact with or are aware of other on-chain scripts.

## Problem Solved

This pattern allows for the creation of large, sophisticated decentralized applications (like a full DeFi ecosystem) without building a single, monolithic contract. It promotes specialization and reuse of on-chain infrastructure.

## When to Use

- **DeFi Protocols**: A DEX might compose with a lending protocol, or a governance contract might control a treasury contract.
- **Upgradable Systems**: By parameterizing a contract with the address of another, you can point it to new versions of its dependencies.
- **Shared Infrastructure**: Using a common, on-chain identity or oracle system across multiple applications.

## Implementation

Composability is often achieved by parameterizing a validator with the address or validator hash of another script. The validator can then enforce rules about how transactions interact with that other script.

### Example: Governance Controlling a Treasury

Here, a `governance` validator is parameterized with the address of a `treasury` validator. It can then create transactions that the `treasury` validator will accept.

```aiken
// A simple treasury validator controlled by an admin
validator treasury(admin: ByteArray) {
  spend(_: Void, withdrawal_amount: Int, context: ScriptContext) -> Bool {
    and {
      // Must be signed by the admin
      list.has(context.transaction.extra_signatories, admin),
      // Business logic...
    }
  }
}

// A governance validator that ACTS AS the admin for the treasury
validator governance(treasury_address: Address, treasury_admin: ByteArray) {
  spend(proposal: Proposal, _: Void, context: ScriptContext) -> Bool {
    // 1. Check that the proposal has passed
    let proposal_passed = proposal.votes_for > proposal.votes_against

    // 2. Find the output going to the treasury
    let treasury_output =
      list.find(context.transaction.outputs, fn(output) {
        output.address == treasury_address
      })

    // 3. Verify the governance contract is correctly interacting with the treasury
    let treasury_interaction_valid =
      when treasury_output is {
        Some(out) ->
          // The governance contract ensures the payment to the treasury
          // matches the proposal's intent.
          assets.lovelace_of(out.value) == proposal.payment_amount
        None -> False
      }

    and {
      proposal_passed,
      treasury_interaction_valid,
    }
  }
}
```

In this system, the `treasury_admin` for the `treasury` contract would be the validator hash of the `governance` contract itself, creating a secure, programmatic link.

## Security Considerations

- **Interface Stability**: When contracts depend on each other, changes to one can break the other. This is especially true for datum structures.
- **Reentrancy (Not an Issue on Cardano)**: Unlike account-based models (e.g., Ethereum), the UTxO model is not vulnerable to traditional reentrancy attacks, which simplifies composability.
- **Dependency Audits**: When composing contracts, the security of your system is the security of its weakest link. All composed contracts must be audited.

## Related Topics

- [Reusability](./reusability.md)
- [DAO Governance Example](../code-examples/dao-governance.md)
- [Validators](../language/validators.md)

## References

- [Cardano's UTxO Model and Composability](https://docs.cardano.org/learn/eutxo-explainer)
