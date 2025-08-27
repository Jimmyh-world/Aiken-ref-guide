# Aiken Control Flow

## Overview

Aiken provides several constructs for controlling the flow of execution, including `if/else` expressions, `when` for pattern matching, and logical blocks like `and` and `or`.

## Key Concepts

- **Expression-Based**: All control flow constructs in Aiken are expressions that return a value.
- **Pattern Matching**: The `when` expression is a powerful tool for branching logic based on the structure of data.
- **Short-Circuiting**: `and` and `or` blocks provide a readable way to handle logical operations.
- **`expect` Keyword**: A special construct for asserting a pattern match; if it fails, the entire script fails.
- **`?` Operator**: A debug operator that traces a message if the expression it's attached to evaluates to `False`.

## `if/else` Expressions

An `if/else` expression evaluates a condition and returns a value from one of two branches.

```aiken
let message = if x > 5 { "greater" } else { "not greater" }
```

## `when` Expressions (Pattern Matching)

The `when` expression matches a value against several patterns. It is exhaustive, meaning the compiler will warn you if you haven't covered all possible cases.

```aiken
fn handle_result(result: Result<Int, ByteArray>) -> Int {
  when result is {
    Ok(value) -> value
    Error(_) -> 0
  }
}

// Using guards in patterns
fn classify_number(n: Int) -> ByteArray {
  when n is {
    x if x > 0 -> "positive"
    0 -> "zero"
    _ -> "negative"
  }
}

// Matching multiple patterns with `|`
fn is_weekend(day: ByteArray) -> Bool {
  when day is {
    "saturday" | "sunday" -> True
    _ -> False
  }
}
```

## `and` and `or` Blocks

These blocks provide a more readable way to chain boolean checks.

```aiken
let is_valid = and {
  is_signed,
  fee_is_sufficient,
}
```

## `expect` Keyword

In validators, `expect` asserts that a value must match a pattern. If it doesn't, the script fails immediately.

```aiken
validator {
  spend(datum: Option<MyDatum>, _, _) {
    // Fails if datum is None. Otherwise, binds `owner`.
    expect Some(MyDatum { owner }) = datum
    // ... logic using owner
  }
}
```

## Security Considerations

- **Exhaustive Patterns**: Always ensure your `when` expressions are exhaustive to prevent unexpected failures. The compiler helps enforce this.
- **Use `expect` for Invariants**: Use `expect` for conditions that _must_ be true for the contract to be valid. It makes security-critical assumptions explicit.

## Related Topics

- [Syntax](./syntax.md)
- [Data Structures](./data-structures.md)
- [Validators](./validators.md)

## References

- [Aiken Language Tour: Pattern Matching](https://aiken-lang.org/language-tour/pattern-matching)
