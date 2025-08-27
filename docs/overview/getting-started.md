# Getting Started with Aiken

## Overview

This guide provides the steps to install Aiken, create a new project, and run the basic commands for checking, building, and testing a smart contract.

## Key Concepts

- **`aikup`**: The official installer and version manager for Aiken.
- **`aiken new`**: The command to scaffold a new Aiken project.
- **`aiken build`**: Compiles the project and generates the `plutus.json` blueprint.
- **`aiken check`**: Type-checks the project and runs all tests.
- **`aiken bench`**: Runs performance benchmark tests.

## Installation

`aikup` is a cross-platform utility to download and manage Aiken versions.

### Recommended Installation

```bash
# Linux, macOS, WSL
curl --proto '=https' --tlsv1.2 -LsSf https://install.aiken-lang.org | sh
```

### Alternative Installation Methods

```bash
# Using npm
npm install -g @aiken-lang/aikup

# Using Homebrew on macOS
brew install aiken-lang/tap/aikup

# Using PowerShell on Windows
powershell -c "irm https://windows.aiken-lang.org | iex"
```

### Installing Aiken

Once `aikup` is installed, you can install the latest version of Aiken.

```bash
# Install the latest stable version
aikup

# Install a specific version
aikup install v1.1.11
```

## Creating Your First Project

1. **Create a New Project**

   ```bash
   aiken new my-github-user/hello_world
   cd hello_world
   ```

2. **Project Structure**
   ```
   hello_world/
   ├── aiken.toml         # Project configuration
   ├── lib/               # Library modules
   ├── validators/        # Your smart contract logic
   ├── env/               # Environment-specific modules
   └── README.md
   ```

## Core Development Commands

- **`aiken check`**: Type-checks your code and runs all tests.
- **`aiken build`**: Compiles your validators and generates a `plutus.json` file.
- **`aiken bench`**: Runs all performance benchmarks defined in your tests.
- **`aiken docs`**: Generates HTML documentation for your project.
- **`aiken fmt`**: Formats all Aiken source files in your project.

## Environment-Specific Builds

You can compile your project with different configurations for `testnet` or `mainnet` by using modules in the `env/` directory.

```bash
aiken build --env mainnet
aiken check --env testnet
```

## Related Topics

- [Introduction to Aiken](./introduction.md)
- [Language Syntax](../language/syntax.md)
- [Testing](../language/testing.md)

## References

- [Aiken Documentation: Getting Started](https://aiken-lang.org/getting-started)
