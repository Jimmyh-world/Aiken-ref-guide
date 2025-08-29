---
title: 'Aiken Developer Reference Guide for AI Coding Assistants'
description: 'Comprehensive Aiken smart contract development guide optimized for AI assistants and developers'
tags:
  [
    aiken,
    cardano,
    smart-contracts,
    ai-optimized,
    plutus,
    blockchain,
    cryptocurrency,
  ]
version: 'v1.1.15+'
last_updated: 'December 2024'
status: 'mixed-security'
---

# Aiken Developer's Reference Guide for AI Coding Assistants

[![CI Core](https://github.com/Jimmyh-world/Aiken-ref-guide/workflows/CI%20%E2%80%93%20Core/badge.svg)](https://github.com/Jimmyh-world/Aiken-ref-guide/actions) [![CI Examples](https://github.com/Jimmyh-world/Aiken-ref-guide/workflows/CI%20%E2%80%93%20Examples/badge.svg)](https://github.com/Jimmyh-world/Aiken-ref-guide/actions) [![Docs](https://github.com/Jimmyh-world/Aiken-ref-guide/workflows/Docs/badge.svg)](https://github.com/Jimmyh-world/Aiken-ref-guide/actions) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Welcome to the AI-optimized knowledge base for the Aiken smart contract language on Cardano. This guide is designed for developers and AI coding assistants (like Cursor, Cody, and GitHub Copilot) to quickly find, understand, and implement Aiken smart contracts.

## Version Compatibility

**Aiken Version**: This guide is compatible with Aiken **v1.1.15+** (tested v1.1.15 & v1.1.19)  
**Last Updated**: December 2024  
**Status**: ⚠️ **MIXED SECURITY** - See [SECURITY_STATUS.md](SECURITY_STATUS.md) before deploying ANY example

## 🚨 **CRITICAL SECURITY WARNING**

**NOT ALL EXAMPLES ARE PRODUCTION READY!** This repository contains examples with mixed security implementations:

- ✅ **hello-world, escrow-contract**: Secure (with proper audit for production)
- ❌ **nft-one-shot, fungible-token**: Educational placeholders - **NEVER DEPLOY**

**➡️ CHECK [SECURITY_STATUS.md](SECURITY_STATUS.md) BEFORE USING ANY EXAMPLE**

## Mission

This reference provides a comprehensive, structured, and easily searchable set of documents covering the Aiken language, from basic syntax to advanced security patterns. The content is optimized for Large Language Models (LLMs) to ensure accurate and efficient code generation and problem-solving.

## 🚀 **Quick Deploy with Monitoring**

### **Deploy Changes with Real-Time Validation**

```bash
# Deploy with real-time CI/CD monitoring
git add .
git commit -m "feat: update Aiken documentation"
git push origin main

# Monitor deployment status (requires gh CLI)
gh run list --limit 5
gh run watch  # Real-time workflow monitoring

# Check specific workflow status
gh run list --workflow="CI – Examples" --limit 3
gh run list --workflow="CI – Core" --limit 3
```

### **Advanced Monitoring & Validation**

```bash
# Monitor all workflows simultaneously
gh api repos/:owner/:repo/actions/runs --jq '.workflow_runs[] | select(.status=="in_progress") | {name: .name, status: .status}'

# Check deployment health across all examples
gh workflow list
gh run view --log  # View detailed logs for troubleshooting
```

## How to Use This Guide

### **Quick Start**

- **New to Aiken?** Start with [`QUICK_START.md`](QUICK_START.md) for a 5-minute setup guide
- **Need Navigation?** Use [`NAVIGATION.md`](NAVIGATION.md) to find exactly what you need

### **User Types**

- **AI Assistants**: Ingest the `docs/` directory to provide your language model with a deep understanding of Aiken. The modular structure allows for precise context-sourcing.
- **Developers**: Browse the `docs/` directory to find specific topics. Each file is self-contained but links to related concepts, allowing for easy navigation.
- **New Users**: Follow the user journey paths in [`NAVIGATION.md`](NAVIGATION.md) for guided learning

## Repository Structure

```
aiken/
├── README.md                    # Project overview + quick start
├── NAVIGATION.md               # Repository navigation guide
├── QUICK_START.md              # 5-minute setup guide
├── CONTRIBUTING.md             # Community contribution guidelines
├── .github/workflows/          # CI/CD automation
│   ├── _reusable-aiken-check.yml
│   ├── ci-core.yml
│   ├── ci-examples.yml
│   ├── docs.yml
│   └── release.yml
├── docs/                       # Comprehensive documentation
│   ├── overview/              # Introduction and getting started
│   ├── language/              # Core language syntax and features
│   ├── patterns/              # Design patterns and best practices
│   ├── security/              # Security-first development
│   ├── code-examples/         # Working contract examples
│   ├── performance/           # Optimization and benchmarking
│   ├── integration/           # Off-chain tools and deployment
│   └── references/            # Quick reference and troubleshooting
└── examples/                   # Working project examples
    ├── hello-world/           # Basic validator example
    └── token-contracts/       # Token contract examples
        └── nft-one-shot/      # NFT one-shot minting policy
```

### **Documentation Sections**

- **`docs/overview/`**: Introduction, ecosystem links, and getting started
- **`docs/language/`**: Core language syntax, features, and testing
- **`docs/patterns/`**: Common smart contract design patterns with code
- **`docs/security/`**: Security best practices, vulnerabilities, and checklists
- **`docs/code-examples/`**: Complete, real-world contract examples
- **`docs/performance/`**: Guides for optimizing on-chain execution costs
- **`docs/integration/`**: Off-chain integration, deployment, and monitoring
- **`docs/references/`**: Glossaries, links, and troubleshooting

## Key Features

### **Documentation Excellence**

- **LLM-Optimized**: Short, declarative sentences and a consistent, predictable structure
- **Modular**: Each topic is in its own file, making it easy for AI to find relevant context
- **Code-Centric**: Every concept is supported by working, syntax-highlighted code snippets
- **Secure by Default**: Security considerations are integrated into every relevant topic
- **Cross-Referenced**: Documents are linked to provide a cohesive learning path

### **Production Readiness**

- **Working Examples**: Complete, testable project examples in `examples/`
- **CI/CD System**: Modular workflows with parallel execution and comprehensive validation
- **Multi-User Design**: Clear paths for different user types and experience levels
- **Professional Structure**: Organization that scales with project growth

---

_This guide is maintained to reflect the latest stable version of Aiken. For bleeding-edge features, always consult the official Aiken documentation._
