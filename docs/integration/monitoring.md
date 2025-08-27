# Monitoring and Debugging

## Overview

After deploying a smart contract, it is crucial to monitor its activity for health, performance, and potential security issues. Aiken also provides built-in tools for debugging validator logic during development.

## Key Concepts

- **On-Chain Monitoring**: Observing transactions to and from the script address to understand usage and detect anomalies.
- **Performance Tracking**: Measuring the fees and execution units of real-world transactions to identify performance bottlenecks.
- **Debugging with `trace`**: Using Aiken's `trace` keyword to print messages during validator execution, which is invaluable for debugging complex logic.

## On-Chain Monitoring (Off-Chain)

You can use blockchain explorers or libraries like Lucid with a provider like Blockfrost to monitor your contract.

### Example: Monitoring with Lucid

```typescript
// Monitor for new UTxOs at the contract address
const monitorContract = async (contractAddress: string) => {
  console.log(`Monitoring contract: ${contractAddress}`);
  const utxos = await lucid.provider.getUtxos(contractAddress);

  for (const utxo of utxos) {
    console.log(`Found UTxO: ${utxo.txHash}#${utxo.outputIndex}`);
    // Decode the inline datum to inspect the state
    if (utxo.datum) {
      try {
        const decodedDatum = Data.from(utxo.datum);
        console.log(`Decoded datum:`, decodedDatum);
      } catch (e) {
        console.error(`Could not decode datum: ${e}`);
      }
    }
  }
};

// Periodically check for new activity
setInterval(() => monitorContract(contractAddress), 60000); // Every 60 seconds
```

## Debugging (On-Chain)

Aiken's `trace` keyword is the primary tool for on-chain debugging. When a validator containing `trace` is executed, the messages are printed by the Cardano node, making them visible when evaluating a transaction with `cardano-cli` or in test results.

### Using `trace`

```aiken
validator debug_contract {
  spend(datum: MyDatum, redeemer: Action, context: ScriptContext) -> Bool {
    trace @"--- Validator Execution Start ---"
    trace @"Datum received: "
    trace datum

    let is_valid = perform_validation(datum, redeemer, context)

    trace if is_valid {
      @"Validation succeeded."
    } else {
      @"Validation FAILED."
    }
    trace @"--- Validator Execution End ---"

    is_valid
  }
}
```

### Conditional Tracing with `?`

The `?` operator is a shorthand for `trace if False`. It will print a default trace message if the boolean expression it is attached to is `False`.

```aiken
validator quick_debug {
  spend(datum: MyDatum, _, context: ScriptContext) -> Bool {
    let owner_signed = list.has(context.transaction.extra_signatories, datum.owner)
    let fee_paid = context.transaction.fee > 100_000

    // If owner_signed is False, it will print a trace message.
    owner_signed?

    and {
      owner_signed,
      fee_paid,
    }
  }
}
```

To see trace messages when running tests, use the `--trace` flag: `aiken check --trace all`.

## Related Topics

- [Deployment](./deployment.md)
- [Testing](../language/testing.md)
- [Troubleshooting](../references/troubleshooting.md)

## References

- [Aiken Language Tour: Debugging](https://aiken-lang.org/language-tour/errors-and-debugging)
