# Benchmarking Framework

## Overview

Aiken includes a built-in benchmarking framework that allows you to measure the precise on-chain execution cost (CPU and memory) of your code. This is an essential tool for optimizing smart contracts and ensuring they stay within protocol limits.

## Key Concepts

- **`test bench`**: A test annotated with `bench` is a benchmark test.
- **`aiken bench`**: The command-line tool to run all benchmark tests.
- **Execution Units**: The output of a benchmark run, showing the exact CPU and memory units consumed.
- **Comparative Analysis**: Benchmarking is most effective when comparing different implementations of the same logic to find the most efficient one.

## Writing Benchmark Tests

A benchmark test is simply a regular test function with the `bench` keyword added after `test`.

### Basic Benchmark

This test measures the cost of a single, potentially expensive operation.

```aiken
// This test will be benchmarked for its performance.
test bench list_fold_large() {
  let data = list.range(1, 1000)
  list.foldl(data, 0, fn(acc, x) { acc + x * x })
}
```

### Comparative Benchmark

This is a powerful pattern for comparing two or more approaches to solving the same problem. The test still needs to return `True`, but the benchmark tool will measure the cost of the entire test body.

```aiken
test bench approach_comparison() {
  let data = list.range(1, 500)

  // Approach 1: Map then fold
  let result1 = data
    |> list.map(fn(x) { x * x })
    |> list.foldl(0, fn(acc, x) { acc + x })

  // Approach 2: Direct fold in a single pass
  let result2 = list.foldl(data, 0, fn(acc, x) { acc + x * x })

  // The test ensures both approaches are correct, while the benchmark
  // measures their relative performance.
  result1 == result2
}
```

## Running Benchmarks

Use the `aiken bench` command to run your benchmarks.

```bash
# Run all benchmarks in the project
aiken bench

# Run a specific benchmark by name
aiken bench --match "approach_comparison"

# Get detailed (verbose) output
aiken bench --verbose
```

### Interpreting the Output

The output will show the execution units for each benchmark test:

```
 ✓ bench_test_name
   mem: 12345
   cpu: 67890
```

- **`mem`**: Memory units consumed.
- **`cpu`**: CPU steps consumed.

Your goal is to minimize these numbers while maintaining correct logic.

## Security Considerations

- **Don't Sacrifice Clarity for Micro-optimizations**: Write clear, correct, and secure code first. Use benchmarks to optimize only the parts of your code that are performance-critical.
- **Benchmark Realistic Scenarios**: Ensure your benchmarks test data sizes and conditions that are representative of real-world usage on the mainnet.

## Related Topics

- [Optimization](./optimization.md)
- [Testing](../language/testing.md)
- [CLI Reference](../references/quick-reference.md)

## References

- [Aiken Documentation: Benchmarking](https://aiken-lang.org/fundamentals/testing#benchmarking)
