# Aiken Developer's Reference Guide - Development Branch

**STATUS: IN DEVELOPMENT** - Last Updated: 2025-10-02
**Branch**: development (Latest Features & Experimental Patterns)
**Completion**: 50% (Token contracts in progress, testnet-only deployment)

## Repository Information
- **GitHub Repository**: https://github.com/Jimmyh-world/Aiken-ref-guide
- **Local Directory**: `~/projects/cardano/aiken`
- **Primary Purpose**: Latest Aiken contract features and experimental patterns

## Important Context

This branch contains **work-in-progress contracts** with latest Aiken features. All contracts on this branch are **TESTNET ONLY** and should never be deployed to mainnet without proper review and migration to main branch.

### 5-Branch Architecture

- **main**: Production-ready contracts (stable, audited, mainnet-safe)
- **development** (this branch): Latest features & experimental patterns
- **educational**: Security learning (NEVER deploy - intentionally vulnerable)
- **governance**: Feature branch for voting contracts
- **testnet**: Deployment infrastructure and testing

**Purpose**: This is where new Aiken contracts are developed and refined before promotion to main.

### Integration with .cursor/rules/
This AGENTS.md **complements** .cursor/rules/, following agents.md standard.

## Core Development Principles (MANDATORY)

### 1. KISS (Keep It Simple, Stupid)
- Avoid over-complication and over-engineering
- Choose simple solutions over complex ones
- Question every abstraction layer
- If a feature seems complex, ask: "Is there a simpler way?"

### 2. TDD (Test-Driven Development)
- Write tests first
- Run tests to ensure they fail (Red phase)
- Write minimal code to pass tests (Green phase)
- Refactor while keeping tests green
- Never commit code without tests

### 3. Separation of Concerns (SOC)
- Each module/component has a single, well-defined responsibility
- Clear boundaries between different parts of the system
- Services should be loosely coupled
- Avoid mixing business logic with UI or data access code

### 4. DRY (Don't Repeat Yourself)
- Eliminate code duplication
- Extract common functionality into reusable components
- Use configuration files for repeated settings
- Create shared libraries for common operations

### 5. Documentation Standards
- Always include the actual date when writing documentation
- Use objective, factual language only
- Avoid marketing terms like "production-ready", "world-class", "highly sophisticated", "cutting-edge", etc.
- State current development status clearly
- Document what IS, not what WILL BE

### 6. Jimmy's Workflow (Red/Green Checkpoints)
**MANDATORY for all implementation tasks**

Use the Red/Green/Blue checkpoint system to prevent AI hallucination and ensure robust implementation:

- 🔴 **RED (IMPLEMENT)**: Write code, build features, make changes
- 🟢 **GREEN (VALIDATE)**: Run explicit validation commands, prove it works
- 🔵 **CHECKPOINT**: Mark completion with machine-readable status, document rollback

**Critical Rules:**
- NEVER skip validation phases
- NEVER proceed to next checkpoint without GREEN passing
- ALWAYS document rollback procedures
- ALWAYS use explicit validation commands (not assumptions)

**Reference**: See **JIMMYS-WORKFLOW.md** for complete workflow system, templates, and patterns

**Usage**: When working with AI assistants, say: *"Let's use Jimmy's Workflow to execute this plan"*

**Benefits:**
- Prevents "AI says done ≠ Actually done" problem
- Forces validation at every step
- Enables autonomous execution with safety gates
- Provides clear rollback paths
- Integrates seamlessly with TDD approach

## Project Overview

This branch provides **latest Aiken contract development** with experimental patterns and features. Contracts here are under active development and should only be deployed to testnet.

**Key Responsibilities:**
- Token contract development (fungible, NFTs)
- Advanced Aiken patterns
- Performance optimization experiments
- Integration testing
- Testnet deployment validation

**Important Distinctions:**
- **Development vs Main**: Development has latest features but lower stability
- **Development vs Educational**: Development contracts are functional, educational are intentionally vulnerable
- **Development vs Governance**: Development is general-purpose, governance is feature-specific

## Current Status - Development Branch

🔄 **IN DEVELOPMENT** - 50% (Token contracts in progress)

### Contract Status:
- ✅ **hello-world/** - Complete, stable reference
- ✅ **escrow-contract/** - Complete, ready for review
- 🔄 **token-contracts/** - IN PROGRESS (50% complete)
  - 🔄 fungible-token.ak - Under development
  - ⚪ nft-minting.ak - Not started
  - ⚪ multi-asset.ak - Not started
- ⚪ **voting-contracts/** - Empty (waiting for governance branch merge)

### Quality Gates (Development Branch):
- ✅ All contracts must pass `aiken check`
- ✅ All contracts must pass `aiken test` with >80% coverage
- ✅ At least 1 reviewer approval
- ⚠️ **TESTNET ONLY** - No mainnet deployment allowed

### Next Steps:
1. Complete fungible-token.ak implementation
2. Add comprehensive test suite
3. Deploy to testnet for validation
4. Document patterns and learnings
5. Create NFT minting contract

## Technology Stack

### Smart Contract Development
- **Language**: Aiken v1.1.15+
- **Build Tool**: Aiken CLI
- **Testing**: Aiken built-in test framework
- **Validation**: Property-based testing
- **Deployment Target**: Cardano Preprod/Preview testnets

### Infrastructure
- **Version Control**: Git (5-branch architecture)
- **CI/CD**: GitHub Actions
- **Testing Networks**: Preprod, Preview
- **Documentation**: Markdown

## Build & Test Commands

### Aiken Development
```bash
# Check syntax and types
aiken check

# Run all tests
aiken test

# Run specific test
aiken test -m "test_name"

# Build contracts
aiken build

# Format code
aiken fmt

# Generate documentation
aiken docs
```

### Contract-Specific Commands
```bash
# Token contracts
cd examples/token-contracts
aiken check
aiken test
aiken build

# Hello world (reference)
cd examples/hello-world
aiken check
aiken test

# Escrow contract
cd examples/escrow-contract
aiken check
aiken test
```

### Multi-Branch Operations
```bash
git checkout development  # This branch (latest features)
git checkout main         # Production (stable contracts)
git checkout testnet      # Deploy contracts here
git checkout governance   # Voting contracts feature branch
```

## Repository Structure

```
aiken/
├── examples/
│   ├── hello-world/            # ✅ Complete reference contract
│   │   ├── validators/
│   │   ├── lib/
│   │   └── aiken.toml
│   │
│   ├── escrow-contract/        # ✅ Complete, ready for review
│   │   ├── validators/
│   │   ├── lib/
│   │   └── aiken.toml
│   │
│   ├── token-contracts/        # 🔄 IN PROGRESS (50%)
│   │   ├── validators/
│   │   │   ├── fungible-token.ak      # 🔄 Under development
│   │   │   ├── nft-minting.ak         # ⚪ Not started
│   │   │   └── multi-asset.ak         # ⚪ Not started
│   │   ├── lib/
│   │   └── aiken.toml
│   │
│   └── voting-contracts/       # ⚪ Empty (waiting for governance merge)
│
├── docs/                       # Documentation
├── testnet/                    # Deployment infrastructure (from testnet branch)
├── AGENTS.md                   # This file
└── CLAUDE.md                   # Quick reference
```

## Development Workflow

### Starting Work on a Contract
1. Read this AGENTS.md file for context
2. Check current implementation status above
3. Review known issues and TODOs below
4. **Use Jimmy's Workflow**: Plan → Implement → Validate → Checkpoint
5. Follow TDD approach - write tests first
6. Implement minimal code to pass tests
7. Refactor while maintaining green tests

### Before Committing Code
1. Run syntax check: `aiken check`
2. Run all tests: `aiken test`
3. Format code: `aiken fmt`
4. Build contracts: `aiken build`
5. Update documentation if needed
6. Ensure no secrets are exposed
7. Verify test coverage >80%
8. Use Jimmy's Workflow checkpoints to validate completeness

### Documentation Updates
1. Update README.md with any contract changes
2. Add inline comments for complex Aiken logic
3. Update this AGENTS.md if development approach changes
4. Document all decisions with dates
5. Generate Aiken docs: `aiken docs`

### Promotion Path to Main
```
development → testnet (validate) → main (production)
```

**Requirements before promotion:**
1. All tests passing (`aiken test`)
2. Deployed to testnet successfully
3. Testnet validation complete
4. Security review completed
5. At least 2 reviewer approvals
6. Documentation complete

## Known Issues & Technical Debt

### 🔴 Critical Issues
None blocking development.

### 🟡 Important Issues
1. **Token contracts incomplete** - fungible-token.ak at 50%, NFT not started (2025-10-02)
2. **Test coverage below 80%** - Need more property-based tests for token contracts
3. **No governance contracts** - Waiting for governance branch merge

### 📝 Technical Debt
1. **Complete fungible-token.ak** - Finish implementation and add tests (Estimate: 2 days)
2. **Implement NFT minting** - Create nft-minting.ak contract (Estimate: 3 days)
3. **Add multi-asset support** - Create multi-asset.ak contract (Estimate: 3 days)
4. **Improve test coverage** - Add property-based tests (Estimate: 2 days)
5. **Document Aiken patterns** - Create pattern documentation (Estimate: 1 day)

## Project-Specific Guidelines

### Code Style (Aiken)
- Use snake_case for function names
- Use PascalCase for type names
- Maximum function length: 50 lines
- Always add type annotations
- Document validator logic with comments

### Testing Requirements
- Minimum 80% code coverage
- Unit tests for all validators
- Property-based tests for critical logic
- Integration tests for multi-step workflows
- Test both success and failure cases

### Security Considerations
- **TESTNET ONLY** - Never deploy development branch to mainnet
- Validate all inputs in validators
- Check datum integrity
- Verify signature requirements
- Test edge cases and attack vectors
- Document security assumptions

### Aiken Best Practices
```aiken
// ✅ Good: Clear validator logic
validator my_validator {
  fn spend(datum: Datum, redeemer: Redeemer, ctx: ScriptContext) -> Bool {
    // Clear, documented validation logic
    validate_datum(datum) && validate_signature(ctx)
  }
}

// ❌ Bad: Complex, undocumented logic
validator complex {
  fn spend(d: D, r: R, c: C) -> Bool {
    // Unclear logic without documentation
    d.a && r.b || c.c
  }
}
```

## Common Patterns & Examples

### Pattern: Token Minting Validator
```aiken
// Validate token minting with proper checks
validator token_minting {
  fn mint(redeemer: MintRedeemer, ctx: ScriptContext) -> Bool {
    let ScriptContext { transaction, purpose } = ctx

    expect Mint(policy_id) = purpose

    // Check minting quantity
    let minted = transaction.mint
      |> value.tokens(policy_id)
      |> dict.to_list()

    // Validate minting constraints
    all(minted, fn((name, quantity)) {
      quantity > 0 && quantity <= max_mint
    })
  }
}
```

### Pattern: Escrow with Datum
```aiken
// Escrow contract with proper datum validation
type EscrowDatum {
  seller: Address,
  buyer: Address,
  amount: Int,
}

validator escrow {
  fn spend(datum: EscrowDatum, redeemer: EscrowRedeemer, ctx: ScriptContext) -> Bool {
    let ScriptContext { transaction, purpose } = ctx

    when redeemer is {
      Complete ->
        validate_payment(datum, transaction)
      Cancel ->
        validate_refund(datum, transaction)
    }
  }
}
```

## Dependencies & Integration

### External Services
None - pure on-chain Aiken contracts.

### Related Branches
- **main**: Production contracts (promote here after testnet validation)
- **testnet**: Deployment infrastructure (deploy here for testing)
- **governance**: Voting contracts (will merge into development)
- **educational**: Security learning (reference only, never deploy)

### Integration Points
- Testnet deployment via `testnet/scripts/`
- CI/CD via GitHub Actions
- Documentation generation via `aiken docs`

## Environment Variables

```bash
# Not applicable - Aiken contracts are pure on-chain code
# Deployment environment variables are in testnet branch
```

## Troubleshooting

### Common Issues

**Issue**: `aiken check` fails with type errors
**Solution**: Review type annotations, ensure all types are properly defined and imported.

**Issue**: `aiken test` fails
**Solution**: Check test logic, verify datum/redeemer structures match validator expectations.

**Issue**: `aiken build` produces large artifacts
**Solution**: Review contract complexity, consider splitting into multiple validators.

**Issue**: Contract fails on testnet
**Solution**: Review transaction structure, check datum encoding, verify script purpose.

**Issue**: Test coverage below 80%
**Solution**: Add more test cases, include edge cases, add property-based tests.

## Resources & References

### Internal Documentation
- **Aiken Docs**: Run `aiken docs` to generate contract documentation
- **Testnet Guide**: See `testnet/TESTNET_CONNECTION_GUIDE.md`
- **Jimmy's Workflow**: See `JIMMYS-WORKFLOW.md`

### External Resources
- **Aiken Language**: https://aiken-lang.org/
- **Aiken Tutorial**: https://aiken-lang.org/example--hello-world
- **Cardano Docs**: https://docs.cardano.org/
- **Plutus Core**: https://plutus.readthedocs.io/

## Important Reminders for AI Assistants

1. **This is development branch** - Latest features, testnet only
2. **Use Jimmy's Workflow** for all implementation tasks
3. **Follow TDD** - Write tests before implementation
4. **TESTNET ONLY** - Never deploy to mainnet
5. **80% coverage** - Maintain high test coverage
6. **Run validation** - `aiken check && aiken test && aiken build`
7. **Update this file** as contracts evolve

### Branch-Specific Rules
- **On development branch**: Latest features, experimental patterns
- **Before mainnet**: Must pass testnet validation and security review
- **Quality gate**: >80% coverage, 1+ reviewer approval
- **Deployment path**: development → testnet → main
- **Never deploy**: educational branch code (intentionally vulnerable)

### Aiken-Specific Commands
```bash
aiken check    # Syntax and type checking
aiken test     # Run test suite
aiken build    # Compile contracts
aiken fmt      # Format code
aiken docs     # Generate documentation
```

---

**This document follows the [agents.md](https://agents.md/) standard for AI coding assistants.**

**Last Updated**: 2025-10-02
**Branch**: development
**Project**: Aiken Developer's Reference Guide
