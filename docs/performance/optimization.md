# Execution Cost Optimization

## Overview

Optimizing Aiken smart contracts is critical for minimizing transaction fees and ensuring your contract can run within the Cardano protocol's execution limits. This guide covers common techniques for optimizing memory and CPU usage.

## Key Concepts

- **Execution Units**: The measure of computational cost on Cardano, consisting of CPU steps and memory units. Lower execution units result in lower transaction fees.
- **Protocol Limits**: Transactions have a maximum limit for execution units. A transaction that exceeds these limits will fail.
- **Benchmarking**: The `aiken bench` command is the primary tool for measuring the execution cost of your code.

## Memory Optimization

Memory optimization focuses on reducing the creation of intermediate data structures.

### Anti-Pattern: Creating Intermediate Lists

```aiken
// BAD: Creates a new list for `map`, another for `filter`.
fn inefficient_processing(items: List<Int>) -> Int {
  items
    |> list.map(fn(x) { x * 2 })
    |> list.filter(fn(x) { x > 10 })
    |> list.foldl(0, fn(acc, x) { acc + x })
}
```

### Good Practice: Single Pass with `foldl`

```aiken
// GOOD: Processes the list in a single pass, creating no new lists.
fn efficient_processing(items: List<Int>) -> Int {
  list.foldl(items, 0, fn(acc, x) {
    let doubled = x * 2
    if doubled > 10 {
      acc + doubled
    } else {
      acc
    }
  })
}
```

## CPU Optimization

CPU optimization focuses on reducing the number of computational steps, often by choosing more efficient algorithms.

### Anti-Pattern: Non-Tail-Recursive Functions

Aiken's compiler performs tail-call optimization. Functions that are not tail-recursive can consume more stack space and CPU steps.

```aiken
// BAD: The addition `head + ...` happens *after* the recursive call.
// This is not tail-recursive.
fn slow_sum(numbers: List<Int>) -> Int {
  when numbers is {
    [] -> 0
    [head, ..tail] -> head + slow_sum(tail)
  }
}
```

### Good Practice: Tail Recursion with an Accumulator

```aiken
// GOOD: The recursive call is the very last action.
fn fast_sum(numbers: List<Int>) -> Int {
  sum_helper(numbers, 0)
}

fn sum_helper(numbers: List<Int>, acc: Int) -> Int {
  when numbers is {
    [] -> acc
    [head, ..tail] -> sum_helper(tail, acc + head)
  }
}
```

## Efficient Validation Patterns

Avoid traversing the same list multiple times in a validator.

```aiken
// BAD: Each check traverses a list.
validator inefficient_validator {
  spend(datum: MyDatum, _, context: ScriptContext) -> Bool {
    let tx = context.transaction
    and {
      !list.is_empty(tx.inputs),
      list.has(tx.extra_signatories, datum.admin),
      !list.is_empty(tx.outputs),
    }
  }
}

// GOOD: The checks are still separate, but `!list.is_empty` is
// generally cheaper than a full traversal like `list.has`.
// The structure is clear and often optimized well by the compiler.
```

## Related Topics

- [Benchmarking](./benchmarking.md)
- [Testing](../language/testing.md)
- [Anti-patterns](../security/anti-patterns.md)

## References

- [Aiken Documentation: Performance](https://aiken-lang.org/performance-considerations)
