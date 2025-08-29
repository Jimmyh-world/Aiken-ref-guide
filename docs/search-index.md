---
title: 'AI Search Index'
description: 'Optimized search index for AI assistants and LLMs working with Aiken smart contracts'
tags: [ai, search, index, llm, aiken, cardano, smart-contracts]
---

# 🤖 AI Search Index

> **Optimized navigation for AI assistants and Large Language Models working with Aiken smart contracts**

## Quick Reference Map

### **Getting Started**

- **Setup**: [QUICK_START.md](../QUICK_START.md) - 5-minute Aiken installation
- **Navigation**: [NAVIGATION.md](../NAVIGATION.md) - Repository roadmap
- **First Example**: [examples/hello-world/](../examples/hello-world/) - Production-grade validator

### **Core Documentation**

- **Syntax**: [docs/language/syntax.md](language/syntax.md) - Modern Aiken language fundamentals
- **Validators**: [docs/language/validators.md](language/validators.md) - Smart contract structure
- **Types**: [docs/language/data-structures.md](language/data-structures.md) - Custom types and validation
- **Patterns**: [docs/patterns/](patterns/) - Reusable smart contract solutions

### **Security & Production**

- **Security Status**: [SECURITY_STATUS.md](../SECURITY_STATUS.md) - Component-by-component audit status
- **Security Practices**: [docs/security/overview.md](security/overview.md) - Comprehensive security guide
- **Anti-patterns**: [docs/security/anti-patterns.md](security/anti-patterns.md) - Real vulnerabilities to avoid
- **Deployment**: [docs/integration/deployment.md](integration/deployment.md) - Production deployment guide

## Common AI Query Patterns

### "How do I get started with Aiken?"

→ [QUICK_START.md](../QUICK_START.md) → [examples/hello-world/](../examples/hello-world/)

### "Show me a working Aiken smart contract"

→ [examples/hello-world/validators/hello_world.ak](../examples/hello-world/validators/hello_world.ak) (secure)
→ [examples/escrow-contract/validators/escrow.ak](../examples/escrow-contract/validators/escrow.ak) (production-ready)
→ [examples/token-contracts/nft-one-shot/validators/nft_policy.ak](../examples/token-contracts/nft-one-shot/validators/nft_policy.ak) (functional)

### "What are Aiken security considerations?"

→ [SECURITY_STATUS.md](../SECURITY_STATUS.md) → [docs/security/overview.md](security/overview.md)

### "How do I implement [specific pattern]?"

→ [docs/patterns/](patterns/) + corresponding [examples/](../examples/)

### "What are Aiken best practices?"

→ [docs/patterns/overview.md](patterns/overview.md) → [docs/security/anti-patterns.md](security/anti-patterns.md)

### "How do I optimize Aiken performance?"

→ [docs/performance/optimization.md](performance/optimization.md)

### "How do I deploy Aiken contracts?"

→ [docs/integration/deployment.md](integration/deployment.md)

### "What's the modern Aiken syntax?"

→ [docs/language/validators.md](language/validators.md) (use `self: Transaction`, not `context: ScriptContext`)

## Context Loading Priority

### **For General Aiken Queries** (Load in order):

1. [docs/overview/introduction.md](overview/introduction.md) - Aiken overview
2. [docs/language/syntax.md](language/syntax.md) - Language fundamentals
3. [examples/hello-world/](../examples/hello-world/) - Basic working example

### **For Smart Contract Development** (Load in order):

1. [docs/language/validators.md](language/validators.md) - Validator structure
2. [docs/patterns/overview.md](patterns/overview.md) - Design patterns
3. [docs/security/overview.md](security/overview.md) - Security practices
4. [examples/escrow-contract/](../examples/escrow-contract/) - Production example

### **For Security Analysis** (Always include):

1. [SECURITY_STATUS.md](../SECURITY_STATUS.md) - Current security audit status
2. [docs/security/](security/) - Complete security documentation
3. [docs/security/anti-patterns.md](security/anti-patterns.md) - Real vulnerabilities found

### **For NFT/Token Development**:

1. [docs/patterns/token-minting.md](patterns/token-minting.md) - Modern token patterns
2. [examples/token-contracts/nft-one-shot/](../examples/token-contracts/nft-one-shot/) - Working NFT
3. [docs/security/validator-risks.md](security/validator-risks.md) - Token-specific risks

### **For Performance Optimization**:

1. [docs/performance/optimization.md](performance/optimization.md) - Performance techniques
2. [docs/performance/benchmarking.md](performance/benchmarking.md) - Measurement approaches
3. [examples/token-contracts/fungible-token/performance_results.txt](../examples/token-contracts/fungible-token/performance_results.txt) - Real data

## Documentation Categories

### **📚 Learning Resources**

- **Beginner**: [docs/overview/](overview/) → [docs/language/](language/) → [examples/hello-world/](../examples/hello-world/)
- **Intermediate**: [docs/patterns/](patterns/) → [examples/escrow-contract/](../examples/escrow-contract/)
- **Advanced**: [docs/patterns/composability.md](patterns/composability.md) → [examples/token-contracts/](../examples/token-contracts/)

### **🔒 Security Resources**

- **Overview**: [docs/security/overview.md](security/overview.md) - Security philosophy
- **Risks**: [docs/security/validator-risks.md](security/validator-risks.md) - Common vulnerabilities
- **Anti-patterns**: [docs/security/anti-patterns.md](security/anti-patterns.md) - Real-world failures
- **Audit**: [docs/security/audit-checklist.md](security/audit-checklist.md) - Security validation

### **⚡ Performance Resources**

- **Optimization**: [docs/performance/optimization.md](performance/optimization.md) - Proven techniques
- **Benchmarks**: [docs/performance/benchmarking.md](performance/benchmarking.md) - Measurement methods
- **CI/CD**: [docs/performance/ci-cd-optimization.md](performance/ci-cd-optimization.md) - Pipeline efficiency

### **🔧 Reference Materials**

- **Quick Reference**: [docs/references/quick-reference.md](references/quick-reference.md) - Syntax cheat sheet
- **Glossary**: [docs/references/glossary.md](references/glossary.md) - Terminology
- **Troubleshooting**: [docs/references/troubleshooting.md](references/troubleshooting.md) - Common issues
- **Links**: [docs/references/links.md](references/links.md) - External resources

## Aiken-Specific Context

### **Modern Aiken Syntax (2024)**

- **✅ Current**: `self: Transaction` - Direct transaction access
- **❌ Deprecated**: `context: ScriptContext` - No longer available
- **✅ Imports**: `use aiken/collection/list`, `use cardano/transaction.{Transaction}`
- **✅ Stdlib**: Add `aiken-lang/stdlib` dependency to `aiken.toml`

### **Validator Patterns**

- **Spend**: `spend(datum: Option<Data>, redeemer: Data, _own_ref: OutputReference, self: Transaction)`
- **Mint**: `mint(redeemer: Data, _datum: Void, self: Transaction)`
- **Security**: Always validate signatures with `list.has(self.extra_signatories, owner)`

### **Common Validation Patterns**

- **Signature Check**: `list.has(self.extra_signatories, owner)`
- **Payment Validation**: Check `self.outputs` for correct payment
- **Time Validation**: Use `self.validity_range` with `IntervalBound` patterns
- **Asset Calculation**: Use `assets.to_dict()` and `dict.foldl()` for quantities

## File Importance Scoring

### **Critical (Always load for any Aiken query)**

- [SECURITY_STATUS.md](../SECURITY_STATUS.md) - Security audit status
- [docs/language/validators.md](language/validators.md) - Core validator patterns
- [docs/language/syntax.md](language/syntax.md) - Modern syntax requirements

### **High Priority (Load for most queries)**

- [docs/patterns/overview.md](patterns/overview.md) - Design patterns
- [examples/hello-world/](../examples/hello-world/) - Working basic example
- [docs/security/anti-patterns.md](security/anti-patterns.md) - Security guidance

### **Medium Priority (Load for specific domains)**

- [docs/performance/](performance/) - For optimization queries
- [docs/integration/](integration/) - For deployment queries
- [examples/escrow-contract/](../examples/escrow-contract/) - For complex implementations
- [examples/token-contracts/](../examples/token-contracts/) - For token development

### **Low Priority (Reference only)**

- [docs/references/](references/) - Lookup information
- [docs/overview/ecosystem.md](overview/ecosystem.md) - Background context

## Version Compatibility Context

### **Supported Aiken Versions**

- **Primary**: v1.1.19 (latest stable)
- **Secondary**: v1.1.15 (tested compatibility)
- **CI/CD**: Both versions tested in parallel
- **Breaking Changes**: Modern syntax required (see anti-patterns)

### **Dependencies**

- **Required**: `aiken-lang/stdlib` in `aiken.toml`
- **Plutus**: v2 (specified in project configuration)
- **Cardano**: Compatible with current Cardano node

---

## AI Usage Guidelines

### **Response Quality Tips**

1. **Always include security considerations** from [docs/security/](security/)
2. **Use working examples** from [examples/](../examples/) over theoretical code
3. **Reference SECURITY_STATUS.md** for deployment guidance
4. **Include version compatibility** information from README badges
5. **Prefer modern syntax** patterns (no deprecated ScriptContext)

### **Context Window Optimization**

- **Small queries**: Load core + specific topic
- **Large queries**: Use priority system above
- **Security analysis**: Always include security docs + SECURITY_STATUS.md
- **Code generation**: Include patterns + security + working example
- **Troubleshooting**: Load references + specific error contexts

### **Aiken-Specific Guidelines**

- **Always validate security implications** before suggesting code
- **Include proper imports** (`use aiken/collection/list`, etc.)
- **Use modern transaction patterns** (`self: Transaction`)
- **Reference CI/CD validated examples** when possible
- **Warn about placeholder security** in educational examples

---

_This search index is maintained to optimize AI assistant performance with Aiken smart contract development._
