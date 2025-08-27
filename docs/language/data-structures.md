# Aiken Data Structures

## Overview

Aiken provides a set of built-in data structures for modeling on-chain data, including lists, tuples, and options. It also allows developers to define their own custom types using records and sum types.

## Key Concepts

- **Homogeneous Lists**: Lists in Aiken can only hold elements of the same type.
- **Heterogeneous Tuples**: Tuples can hold elements of different types and have a fixed size.
- **Custom Types**: The `type` keyword allows for creating complex data structures.
- **Records (Product Types)**: Custom types with named fields, similar to structs.
- **Sum Types (Enums)**: Custom types with multiple constructors, representing a choice between different shapes of data.
- **Generics**: Types can be parameterized to work with any other type.

## Built-in Data Structures

### Lists

```aiken
let numbers: List<Int> = [1, 2, 3, 4, 5]
let empty_list: List<String> = []
```

### Tuples

```aiken
let pair: (Int, String) = (42, "Aiken")
let (the_number, the_string) = pair
```

### `Option<t>`

The `Option` type represents a value that may or may not be present. It has two constructors: `Some(t)` and `None`.

```aiken
let some_value: Option<Int> = Some(10)
let no_value: Option<Int> = None
```

## Custom Types

### Records (Product Types)

Records are custom types with named fields. If a type has only one constructor, you can access its fields using dot notation.

```aiken
type Person {
  name: ByteArray,
  age: Int,
}

let alice = Person { name: "Alice", age: 30 }
let alice_age = alice.age // 30
```

### Sum Types

Sum types define a type that can have one of several different structures.

```aiken
type Action {
  Mint { quantity: Int }
  Burn { quantity: Int }
  Transfer { recipient: ByteArray }
}

let mint_action = Mint { quantity: 1000 }
```

### Generic Types

Types can be parameterized with generic type variables.

```aiken
type Result<data, error> {
  Ok(data)
  Error(error)
}

let success: Result<Int, String> = Ok(42)
```

## Security Considerations

- **Use Custom Types over `Data`**: For datums and redeemers, always define custom types. This allows the Aiken compiler to perform static checks and ensures type safety, preventing a whole class of on-chain errors.
- **Avoid Deeply Nested Structures**: Very complex data structures can be expensive to deserialize and process on-chain. Aim for flat and efficient data models.

## Related Topics

- [Syntax](./syntax.md)
- [Validators](./validators.md)
- [State Machine Pattern](../patterns/state-machines.md)

## References

- [Aiken Language Tour: Custom Types](https://aiken-lang.org/language-tour/custom-types)
