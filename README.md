# Aiken Developer's Reference Guide for AI Coding Assistants

[![CI/CD Pipeline](https://github.com/Jimmyh-world/Aiken-ref-guide/workflows/CI/CD%20Pipeline/badge.svg)](https://github.com/Jimmyh-world/Aiken-ref-guide/actions)

Welcome to the AI-optimized knowledge base for the Aiken smart contract language on Cardano. This guide is designed for developers and AI coding assistants (like Cursor, Cody, and GitHub Copilot) to quickly find, understand, and implement Aiken smart contracts.

## Version Compatibility

**Aiken Version**: This guide is compatible with Aiken **v1.8.0+**  
**Last Updated**: August 2024  
**Status**: ✅ **Production Ready** - All examples tested and validated

## Mission

This reference provides a comprehensive, structured, and easily searchable set of documents covering the Aiken language, from basic syntax to advanced security patterns. The content is optimized for Large Language Models (LLMs) to ensure accurate and efficient code generation and problem-solving.

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
│   └── ci.yml
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
    └── hello-world/           # Basic validator example
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
- **CI/CD Pipeline**: Automated testing and quality assurance
- **Multi-User Design**: Clear paths for different user types and experience levels
- **Professional Structure**: Organization that scales with project growth

---

_This guide is maintained to reflect the latest stable version of Aiken. For bleeding-edge features, always consult the official Aiken documentation._
