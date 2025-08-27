# Tagged Output Pattern

## Overview

The Tagged Output Pattern is a crucial security mechanism in Aiken used to prevent "double satisfaction" attacks. It works by creating a unique, verifiable link between a validator's input and its corresponding output within the same transaction.

## Key Concepts

- **Double Satisfaction**: A vulnerability where an attacker uses a single validator execution to justify multiple malicious actions within one transaction, because the validator logic isn't tied to a specific input/output pair.
- **Tagging**: The process of embedding a unique identifier from the input UTxO (specifically its `OutputReference`) into the datum of the continuing output.
- **One-to-One Mapping**: This pattern enforces a strict one-to-one relationship between the UTxO being spent and the new UTxO being created, ensuring the validator's logic applies only to that pair.

## Problem Solved

This pattern solves the double satisfaction vulnerability, which is common in contracts that process multiple inputs from the same script, such as AMM swaps or batch processing validators.

## When to Use

- **Marketplace and Swap Contracts**: To ensure each swap input corresponds to exactly one valid payment output.
- **Batch Processing Validators**: When a single transaction spends multiple UTxOs from your script to perform multiple actions.
- **Any contract where a validator's logic could be ambiguously applied** across multiple inputs/outputs.

## Implementation

The core idea is to wrap the continuing datum in a new type that includes the `OutputReference` of the input being spent.

```aiken
type MyDatum {
  // ... original datum fields
}

// A wrapper datum used for tagging
type TaggedDatum {
  original_datum: MyDatum,
  input_ref: OutputReference,
}

validator tagged_validator {
  spend(datum: MyDatum, redeemer: MyRedeemer, own_ref: OutputReference, ctx: ScriptContext) {
    // Find outputs that are explicitly tagged with this input's reference
    let tagged_outputs = list.filter(ctx.transaction.outputs, fn(output) {
      when output.datum is {
        // We expect an inline datum of type TaggedDatum
        InlineDatum(raw_datum) -> {
          expect tagged: TaggedDatum = raw_datum
          // The magic check: is this output tagged with *our* input?
          tagged.input_ref == own_ref
        }
        _ -> False
      }
    })

    // The core security check: ensure exactly one tagged output exists
    and {
      list.length(tagged_outputs) == 1,
      // Now, perform the rest of the validation on that single, verified output
      validate_business_logic(tagged_outputs, datum),
    }
  }
}
```

## Security Considerations

- **Uniqueness is Critical**: The `OutputReference` (`tx_hash` + `output_index`) is guaranteed to be unique on the ledger, making it a perfect tag.
- **Datum Validation**: Always ensure you can correctly deserialize the `TaggedDatum` from the output. Using `expect` is a good way to enforce this.
- **State-Based Alternative**: For state machines, incrementing a `nonce` in the datum serves a similar purpose, ensuring a unique and ordered state transition.

## Related Topics

- [State Machines](./state-machines.md)
- [Validator Risks](../security/validator-risks.md)
- [Escrow Contract Example](../code-examples/escrow-contract.md)

## References

- [Aiken Security: Double Satisfaction](https://aiken-lang.org/security-considerations/double-satisfaction)
