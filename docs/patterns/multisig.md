# Multi-Signature Pattern

## Overview

The Multi-Signature (multisig) pattern requires multiple parties to sign a transaction to authorize an action. It is a fundamental building block for decentralized governance and shared control of funds.

## Problem Solved

This pattern addresses the need for shared ownership or control over on-chain assets or actions. It prevents a single point of failure by distributing authority among a group of participants.

## When to Use

- **Shared Treasuries**: For DAOs or groups to collectively manage funds.
- **Governance Decisions**: To require a council of members to approve proposals.
- **High-Security Vaults**: To protect high-value assets by requiring multiple keys.

## Implementation

The datum stores a list of authorized public key hashes and a required signature threshold. The validator checks that at least `threshold` number of signatories have signed the transaction.

```aiken
type MultisigDatum {
  signatories: List<ByteArray>,
  threshold: Int,
}

validator multisig {
  spend(datum: MultisigDatum, _: Void, context: ScriptContext) -> Bool {
    let tx_signatories = context.transaction.extra_signatories

    // Count how many of the required signatories have signed
    let signed_count =
      list.foldl(datum.signatories, 0, fn(acc, required_signer) {
        if list.has(tx_signatories, required_signer) {
          acc + 1
        } else {
          acc
        }
      })

    // Check if the count meets the threshold
    signed_count >= datum.threshold
  }
}
```

## Security Considerations

- **Threshold Management**: A threshold that is too low defeats the purpose of multisig, while one that is too high risks a permanent loss of funds if keys are lost.
- **Key Security**: The overall security depends on the operational security of each individual keyholder.
- **Signatory List Updates**: If the signatory list can be changed, this state transition must be strictly validated (e.g., by a vote of the existing signatories).

## Related Topics

- [State Machines](./state-machines.md)
- [DAO Governance Example](../code-examples/dao-governance.md)
- [Validator Risks](../security/validator-risks.md)

## References

- [Aiken Documentation: Common Design Patterns](https://aiken-lang.org/fundamentals/common-design-patterns)
