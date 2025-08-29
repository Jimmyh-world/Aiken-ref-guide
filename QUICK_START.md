---
title: 'Aiken Quick Start Guide'
description: 'Get up and running with Aiken smart contract development in 5 minutes'
tags: [aiken, quickstart, cardano, smart-contracts, installation, setup]
estimated_time: '5 minutes'
difficulty: 'beginner'
prerequisites: ['Rust toolchain', 'Git', 'Basic terminal knowledge']
version_compatibility: 'v1.1.15+'
---

# Quick Start Guide - Aiken in 5 Minutes

## 🚀 **Get Started with Aiken Smart Contracts**

This guide will have you writing and testing your first Aiken smart contract in under 5 minutes.

---

## 📋 **Prerequisites**

- **Operating System**: macOS, Linux, or Windows (WSL)
- **Memory**: At least 4GB RAM
- **Storage**: 2GB free space
- **Network**: Internet connection for installation
- **Aiken Version**: This guide uses Aiken v1.1.14+ (latest stable)

---

## ⚡ **Step 1: Install Aiken (1 minute)**

### **macOS (using Homebrew)**

```bash
brew install aiken-lang/tap/aiken
```

### **Linux/Windows (using curl)**

```bash
curl --proto '=https' --tlsv1.2 -LsSf https://install.aiken-lang.org | sh
```

### **Verify Installation**

```bash
aiken --version
```

---

## 🏗️ **Step 2: Create Your First Project (1 minute)**

```bash
# Create a new project
aiken new my-user/hello-world
cd hello-world

# Check the project structure
ls -la
```

You should see:

```
hello-world/
├── aiken.toml         # Project configuration
├── validators/        # Smart contract logic
├── lib/              # Library modules
└── README.md
```

---

## ✍️ **Step 3: Write Your First Contract (2 minutes)**

Create `validators/hello_world.ak`:

```aiken
use aiken/list

type Datum {
  owner: ByteArray,
}

validator {
  spend(datum: Datum, redeemer: ByteArray, context: ScriptContext) -> Bool {
    let tx = context.transaction

    let must_say_hello = redeemer == "Hello, World!"
    let must_be_signed = list.has(tx.extra_signatories, datum.owner)

    and {
      must_say_hello,
      must_be_signed,
    }
  }
}
```

Create `lib/hello_world/hello_world_test.ak`:

```aiken
use aiken/list
use hello_world/hello_world.{spend}

test spend_succeeds() {
  let owner_key = #"00010203"
  let datum = Datum { owner: owner_key }
  let redeemer = "Hello, World!"
  let context = mock_context([owner_key])

  spend(datum, redeemer, context)
}

test spend_fails_wrong_message() {
  let owner_key = #"00010203"
  let datum = Datum { owner: owner_key }
  let redeemer = "Wrong message"
  let context = mock_context([owner_key])

  !spend(datum, redeemer, context)
}
```

---

## 🧪 **Step 4: Test Your Contract (1 minute)**

```bash
# Run all tests
aiken check

# You should see:
# ✓ spend_succeeds
# ✓ spend_fails_wrong_message
#
# All tests passed! 🎉
```

---

## 🏗️ **Step 5: Build Your Contract**

```bash
# Build the project
aiken build

# Check the output
ls -la build/
```

---

## 🎉 **Congratulations!**

You've successfully:

- ✅ Installed Aiken
- ✅ Created your first project
- ✅ Written a smart contract
- ✅ Added comprehensive tests
- ✅ Built the project

---

## 🚀 **What's Next?**

### **Learn More**

- **Language Basics**: [`docs/language/syntax.md`](docs/language/syntax.md)
- **Design Patterns**: [`docs/patterns/overview.md`](docs/patterns/overview.md)
- **Security Best Practices**: [`docs/security/overview.md`](docs/security/overview.md)

### **Build Real Contracts**

- **Token Contract**: [`docs/code-examples/token-contract.md`](docs/code-examples/token-contract.md)
- **Escrow Contract**: [`docs/code-examples/escrow-contract.md`](docs/code-examples/escrow-contract.md)
- **DAO Governance**: [`docs/code-examples/dao-governance.md`](docs/code-examples/dao-governance.md)

### **Deploy to Cardano**

- **Testnet Deployment**: [`docs/integration/deployment.md`](docs/integration/deployment.md)
- **Off-chain Integration**: [`docs/integration/offchain-tools.md`](docs/integration/offchain-tools.md)

---

## 🔧 **Troubleshooting**

### **Installation Issues**

```bash
# If curl install fails, try:
wget -O - https://install.aiken-lang.org | sh

# Or download manually from:
# https://github.com/aiken-lang/aiken/releases
```

### **Build Issues**

```bash
# Clean and rebuild
aiken clean
aiken build

# Check for syntax errors
aiken check --trace all
```

### **Test Issues**

```bash
# Run specific test
aiken check --match "spend_succeeds"

# Run with debug output
aiken check --trace all
```

---

## 📚 **Additional Resources**

- **Complete Documentation**: [`docs/`](docs/)
- **Navigation Guide**: [`NAVIGATION.md`](NAVIGATION.md)
- **Official Aiken Docs**: [aiken-lang.org](https://aiken-lang.org/)
- **Community Discord**: [discord.gg/aiken-lang](https://discord.gg/aiken-lang)

---

_This quick start guide gets you up and running in 5 minutes. For comprehensive learning, explore the full documentation in the `docs/` directory._
