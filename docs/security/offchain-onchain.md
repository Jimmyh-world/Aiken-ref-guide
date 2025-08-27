# Off-chain vs. On-chain Responsibilities

## Overview

A secure Cardano dApp relies on a clear and strict separation of responsibilities between off-chain code (which builds transactions) and on-chain code (which validates them). Misunderstanding this separation is a common source of vulnerabilities.

## Key Concepts

- **On-chain Code (Aiken Validators)**: The ultimate source of truth and security. Its only job is to validate a given transaction against a set of rules. It must be completely self-contained and assume nothing about how the transaction was built.
- **Off-chain Code (JavaScript, Python, etc.)**: The "user-facing" part of the dApp. It is responsible for business logic, user interaction, and constructing transactions that conform to the on-chain validator's rules.
- **The Untrusted Boundary**: The transaction itself is the data that crosses the boundary from the untrusted off-chain world to the trusted on-chain world.

## Best Practices for Separation

### On-Chain Responsibilities (The Validator)

- **DO**: Validate everything. Assume the entire transaction is crafted by an attacker.
- **DO**: Keep logic minimal and focused. The validator should only answer "Is this transaction valid for this UTxO?"
- **DO NOT**: Implement complex business logic. This should be handled off-chain.
- **DO NOT**: Trust any data from the redeemer or datum without validating it against the transaction context.

### Off-chain Responsibilities (The dApp Backend/Frontend)

- **DO**: Implement the user experience and business logic.
- **DO**: Construct valid transactions that you know the on-chain validator will accept.
- **DO**: Query the blockchain to get the current state (UTxOs) needed to build a transaction.
- **DO NOT**: Assume that because your off-chain code is correct, nobody can build a different transaction. An attacker will always bypass your off-chain code and interact with the validator directly.

## Secure Architecture Example

This example shows the clear separation for a simple payment contract.

### On-Chain: Simple Validation

The Aiken validator does nothing but check the core conditions.

```aiken
// On-chain: Simple, strict validation
validator payment_validator {
  spend(datum: PaymentDatum, _: Void, context: ScriptContext) -> Bool {
    and {
      // 1. Is the correct amount paid to the recipient?
      check_payment(context.transaction, datum.recipient, datum.amount),
      // 2. Is the transaction submitted before the deadline?
      check_deadline(context.transaction, datum.deadline),
    }
  }
}
```

### Off-Chain: Business Logic and Transaction Construction

The off-chain code handles calculations and builds the transaction.

```typescript
// Off-chain: Business logic and construction (TypeScript example)
class PaymentService {
  async createPaymentTx(recipient: Address, amount: Lovelace): Promise<Tx> {
    // 1. Business logic: calculate fees, deadlines, etc.
    const fee = this.calculateFee(amount);
    const deadline = this.calculateDeadline();
    const validatedRecipient = this.validateRecipientAddress(recipient);

    // 2. Create the datum with the results of the business logic
    const datum = Data.to({
      recipient: validatedRecipient,
      amount: amount,
      deadline: deadline,
    });

    // 3. Construct the transaction that satisfies the on-chain validator
    const tx = await this.lucid
      .newTx()
      .payToContract(contractAddress, { inline: datum }, { lovelace: amount })
      .validTo(deadline)
      .complete();

    return tx;
  }
}
```

## Security Considerations

- **The Validator is Your Only Guard**: An attacker will never use your dApp's frontend. They will read your on-chain code and try to build a transaction that exploits it. Your validator is your only line of defense.
- **Off-chain Code for Liveness**: While the off-chain code doesn't enforce security, it is critical for the "liveness" of your dApp (i.e., ensuring valid transactions can be built and submitted).

## Related Topics

- [Security Overview](./overview.md)
- [Off-chain Tools](../integration/offchain-tools.md)

## References

- [Cardano Developer Portal: Transaction Lifecycle](https://developers.cardano.org/docs/transaction-lifecycle/)
