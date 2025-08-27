# Aiken Modules

## Overview

Aiken uses a module system to organize code into logical units, control visibility, and manage dependencies. This promotes code reusability and maintainability.

## Key Concepts

- **Module Definition**: Each `.ak` file is a module.
- **`use` Keyword**: Used to import other modules.
- **`pub` Keyword**: Exposes functions, types, or constants to other modules.
- **Qualified Imports**: Accessing module members using the module's name as a prefix.
- **Unqualified Imports**: Importing specific members directly into the current scope.
- **Environment Modules**: Special modules for environment-specific configuration.

## Defining and Using Modules

### Visibility (`pub`)

By default, all definitions are private. Use `pub` to make them public.

```aiken
// In lib/myproject/utils.ak
pub fn is_positive(n: Int) -> Bool {
  n > 0
}
```

### Importing (`use`)

```aiken
// In validators/my_validator.ak

// Qualified import (recommended for functions)
use myproject/utils
let result = utils.is_positive(10)

// Unqualified import (common for types)
use myproject/utils.{MyType}
let instance: MyType = ...

// Aliased import
use myproject/utils as U
let result = U.is_positive(10)
```

## Environment Modules

Aiken supports environment-specific modules in the `env/` directory. This allows you to define different constants for environments like `testnet` and `mainnet`.

```aiken
// In env/mainnet.ak
pub const NETWORK_ID = 1

// In env/testnet.ak
pub const NETWORK_ID = 0
```

Build with a specific environment using the `--env` flag: `aiken build --env mainnet`.

## Security Considerations

- **Avoid Unqualified Imports for Functions**: This can lead to name clashes and reduce code clarity. Prefer qualified imports for functions.
- **Explicitly Public**: Only expose what is necessary using `pub`. Keeping implementation details private reduces the surface area for misuse.

## Related Topics

- [Syntax](./syntax.md)
- [Validators](./validators.md)
- [Reusability Patterns](../patterns/reusability.md)

## References

- [Aiken Language Tour: Modules](https://aiken-lang.org/language-tour/modules)
