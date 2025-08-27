# Testing Framework

## Overview

Aiken provides a first-class, built-in framework for writing unit tests, property-based tests, and performance benchmarks. This allows developers to build robust, reliable, and efficient smart contracts with a high degree of confidence.

## Key Concepts

- **Unit Tests**: Verify specific functions or logic paths with fixed inputs.
- **Property-Based Tests**: Test general properties or invariants of your code using randomly generated inputs via the `fuzz` module.
- **Benchmark Tests**: Measure the on-chain execution cost (CPU and memory) of your code.
- **`fail` Annotation**: Marks a test that is expected to fail, turning a failure into a success.
- **Test Execution**: All tests are run using the `aiken check` command, while benchmarks are run with `aiken bench`.

## Unit Tests

Unit tests are the foundation of testing. They check that a piece of code behaves as expected for a given input.

```aiken
// A simple test for an 'add' function
test addition_works() {
  add(2, 3) == 5
}

// A test that is expected to fail
test expected_failure() fail {
  add(2, 3) == 6  // This test passes because it's marked with 'fail'
}

// Testing a validator by mocking its inputs
test spending_validator_works() {
  let datum = MyDatum { owner: #"abc123", amount: 1000000 }
  let redeemer = MyRedeemer { action: "spend" }
  let context = build_mock_context() // A helper to create a mock ScriptContext

  my_script.spend(Some(datum), redeemer, mock_output_ref(), context)
}
```

## Property-Based Testing

Property-based tests check that certain properties hold true for all possible inputs. Aiken's `fuzz` module generates random data to find edge cases that might break these properties.

```aiken
use aiken/fuzz

// Property: Reversing a list twice results in the original list.
test prop_reverse_twice_is_identity() {
  fuzz.list(fuzz.int(), fn(xs) {
    list.reverse(list.reverse(xs)) == xs
  })
}

// Using a custom generator for a specific range
test prop_valid_amounts() {
  let amount_gen = fuzz.int_between(1, 1000000)
  fuzz.test(amount_gen, fn(amount) {
    amount > 0
  })
}

// Using labels to analyze the distribution of generated test data
test prop_with_labels() {
  fuzz.list(fuzz.int(), fn(xs) {
    let len = list.length(xs)
    if len == 0 {
      fuzz.label("empty")
    } else if len < 5 {
      fuzz.label("small")
    } else {
      fuzz.label("large")
    }
    list.reverse(list.reverse(xs)) == xs
  })
}
```

## Benchmark Tests

Benchmarks are used to measure and optimize the performance of your on-chain code.

```aiken
// A benchmark for an expensive computation
test bench expensive_computation() {
  let large_list = list.range(1, 1000)
  list.foldl(large_list, 0, fn(acc, x) { acc + x * x })
}
```

To run benchmarks, use the command: `aiken bench`.

## Security Considerations

- **Test Invariants**: Use property-based tests to verify core security invariants that must never be broken.
- **Cover Edge Cases**: Write unit tests for edge cases like empty lists, zero values, and deadline boundaries.
- **Negative Testing**: Always write tests with the `fail` annotation to ensure your validator correctly rejects invalid inputs and states.

## Related Topics

- [Validators](./validators.md)
- [Performance & Optimization](../performance/optimization.md)
- [Audit Checklist](../security/audit-checklist.md)

## References

- [Aiken Fundamentals: Testing](https://aiken-lang.org/fundamentals/testing)
