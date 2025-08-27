# Troubleshooting

## Overview

This guide provides solutions to common issues encountered during Aiken development, from compilation errors to on-chain transaction failures.

---

### 1. Compilation and Build Errors

If `aiken build` or `aiken check` fails:

- **Action**: Run the command with the `--verbose` flag to get more detailed error messages.
  ```bash
  aiken build --verbose
  ```

- **Action**: Clear the build cache and try again. This can resolve issues with stale artifacts.
  ```bash
  rm -rf build/
  aiken build
  ```

- **Action**: Check and update your project's dependencies.
  ```bash
  aiken packages check
  aiken packages update
  ```

### 2. Type Errors

The Aiken compiler is strict about types. Common errors include:

- **Mismatched Types**: `let result: Int = "hello"`
  - **Solution**: Ensure the type annotation matches the assigned value's type.
- **Missing Annotations**: A function has an ambiguous type.
  - **Solution**: Add explicit type annotations to function arguments and return values to help the compiler. `fn process(data: Data) -> Bool { ... }`

### 3. Test Failures

If a test is failing unexpectedly:

- **Action**: Run the specific test with verbose output and tracing.
  ```bash
  aiken check --match "my_failing_test" --trace all
  ```
- **Action**: For property-based tests, reduce the number of runs to more quickly isolate the failing input.
  ```bash
  aiken check --match "my_prop_test" --property-max-success 10
  ```

### 4. Validator Logic Errors (On-Chain Failures)

When a transaction fails on-chain, the error is often cryptic. Debugging requires adding `trace` statements to your validator.

- **Action**: Sprinkle `trace` statements throughout your validator to print the state of variables at different points.
  ```aiken
  validator {
    spend(datum, redeemer, ctx) {
      trace @"--- Debug Start ---"
      trace @"Datum received: "
      trace datum
      let result = perform_validation(datum, redeemer, ctx)
      trace @"Validation result: "
      trace result
      result
    }
  }
  ```
- **Action**: Re-run the failing test with `--trace all` to see the output.

### 5. Off-Chain Integration Issues

If your off-chain code can't build or submit a transaction:

- **Check Datum/Redeemer Formatting**: This is the most common issue. Ensure the JSON or object you are serializing into `Data` exactly matches the structure of the custom type defined in Aiken.
- **Check UTxO Availability**: Ensure the wallet has sufficient funds and a suitable UTxO for collateral.
- **Check Execution Units**: The transaction might be failing because it exceeds the protocol's memory or CPU limits. Use `aiken bench` to check your validator's cost.
- **Check Signatories**: Ensure the transaction is being signed by all required parties (e.g., the user's wallet, any required multisig keys).
