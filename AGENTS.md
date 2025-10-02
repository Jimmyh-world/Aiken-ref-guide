# Aiken Developer's Reference Guide - Governance Branch

**STATUS: FEATURE BRANCH** - Last Updated: 2025-10-02
**Branch**: governance (Voting Contracts Feature Development)
**Completion**: 60% (Two voting contracts complete, more planned)

## Repository Information
- **GitHub Repository**: https://github.com/Jimmyh-world/Aiken-ref-guide
- **Local Directory**: `~/projects/cardano/aiken`
- **Primary Purpose**: Feature development for voting and governance contracts

## Important Context

This branch contains **feature development for voting and governance contracts**. Currently implements two complete voting contracts with plans for additional governance patterns.

### 5-Branch Architecture

- **main**: Production-ready contracts (stable, audited, mainnet-safe)
- **development**: Latest features & experimental patterns (testnet only)
- **educational**: Security learning (NEVER deploy - intentionally vulnerable)
- **governance** (this branch): Voting contracts feature development
- **testnet**: Deployment infrastructure and testing

**Purpose**: Develop voting and governance contracts before merging to development branch.

**Merge Path**: governance → development → testnet (validate) → main (production)

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

This branch provides **voting and governance contract development** for Cardano. Focus is on creating secure, tested voting mechanisms before merging to development.

**Key Responsibilities:**
- Voting contract implementation
- Governance pattern development
- Security validation for voting logic
- Integration testing
- Documentation of governance patterns

**Important Distinctions:**
- **Governance vs Development**: Governance is feature-specific, development is general-purpose
- **Governance vs Main**: Governance is work-in-progress, main is production-ready
- **Feature Branch**: This branch will merge into development when complete

## Current Status - Governance Branch

✅ **FEATURE DEVELOPMENT** - 60% (Two voting contracts complete)

### Voting Contracts Status:
- ✅ **simple_voting.ak** - COMPLETE
  - Phase 1: Simple signature-based voting
  - Validates voter signatures
  - Counts votes
  - Enforces voting periods
  - Tests passing

- ✅ **municipal_council.ak** - COMPLETE
  - Phase 2: Municipal council governance
  - Multi-signature requirements
  - Council member management
  - Proposal voting system
  - Tests passing

### Planned Additions:
- ⚪ **delegation_voting.ak** - NOT STARTED
  - Delegated voting system
  - Voting power delegation
  - Proxy voting

- ⚪ **quadratic_voting.ak** - NOT STARTED
  - Quadratic voting mechanism
  - Cost-based voting power
  - Sybil resistance

- ⚪ **treasury_governance.ak** - NOT STARTED
  - Treasury fund management
  - Proposal-based spending
  - Multi-sig approvals

### Quality Gates (Governance Branch):
- ✅ All contracts pass `aiken check`
- ✅ All contracts pass `aiken test`
- ✅ Voting logic thoroughly tested
- ✅ Security review completed
- 🔄 Integration tests in progress
- ⚪ Testnet deployment pending

### Next Steps:
1. Complete integration testing for existing contracts
2. Deploy to testnet for validation
3. Document governance patterns
4. Plan delegation_voting.ak implementation
5. Merge to development when stable

## Technology Stack

### Smart Contract Development
- **Language**: Aiken v1.1.15+
- **Build Tool**: Aiken CLI
- **Testing**: Aiken built-in test framework
- **Validation**: Property-based testing
- **Deployment Target**: Feature → development → testnet → main

### Governance Features
- **Signature Validation**: Multi-sig support
- **Voting Mechanisms**: Simple, council, delegation (planned)
- **Time Bounds**: Voting periods and deadlines
- **State Management**: Proposal tracking

## Build & Test Commands

### Aiken Validation Workflow
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

### Voting Contract Commands
```bash
# Simple voting contract
cd examples/voting-contracts
aiken check
aiken test -m "simple_voting"

# Municipal council contract
aiken test -m "municipal_council"

# All voting tests
aiken test
```

### Multi-Branch Operations
```bash
git checkout governance   # This branch (voting contracts)
git checkout development  # Merge target
git checkout testnet      # Deployment testing
git checkout main         # Production (after full validation)
```

## Repository Structure

```
aiken/
├── examples/
│   └── voting-contracts/       # ✅ 60% Complete
│       ├── validators/
│       │   ├── simple_voting.ak          # ✅ Phase 1 - Complete
│       │   ├── municipal_council.ak      # ✅ Phase 2 - Complete
│       │   ├── delegation_voting.ak      # ⚪ Phase 3 - Planned
│       │   ├── quadratic_voting.ak       # ⚪ Phase 4 - Planned
│       │   └── treasury_governance.ak    # ⚪ Phase 5 - Planned
│       │
│       ├── lib/                # Shared governance libraries
│       ├── test/               # Test suite
│       ├── docs/               # Generated documentation
│       ├── build/              # Build artifacts
│       ├── aiken.toml          # Project config
│       ├── plutus.json         # Compiled contracts
│       └── README.md           # Voting contracts documentation
│
├── docs/                       # Documentation
├── AGENTS.md                   # This file
└── CLAUDE.md                   # Quick reference
```

## Development Workflow

### Starting Work on a Voting Contract
1. Read this AGENTS.md file for context
2. Check current implementation status above
3. Review existing voting contracts (simple_voting.ak, municipal_council.ak)
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
7. Verify voting logic is secure
8. Use Jimmy's Workflow checkpoints to validate completeness

### Documentation Updates
1. Update voting-contracts/README.md with contract changes
2. Add inline comments for complex voting logic
3. Update this AGENTS.md if development approach changes
4. Document all decisions with dates
5. Generate Aiken docs: `aiken docs`

### Merge Path to Main
```
governance → development → testnet (validate) → main (production)
```

**Requirements before merging to development:**
1. All tests passing (`aiken test`)
2. Security review completed
3. Voting logic validated
4. Documentation complete
5. At least 2 reviewer approvals

**Requirements before promotion to main:**
1. Merged to development successfully
2. Deployed to testnet successfully
3. Testnet validation complete
4. Full security audit
5. Multiple reviewer approvals

## Known Issues & Technical Debt

### 🔴 Critical Issues
None blocking governance feature development.

### 🟡 Important Issues
1. **Integration tests incomplete** - Need comprehensive multi-contract testing (2025-10-02)
2. **Testnet deployment pending** - Contracts not yet deployed to testnet
3. **Documentation needs expansion** - Governance patterns need detailed docs

### 📝 Technical Debt
1. **Complete integration testing** - Test contract interactions (Estimate: 2 days)
2. **Deploy to testnet** - Validate on testnet (Estimate: 1 day)
3. **Implement delegation voting** - Phase 3 contract (Estimate: 4 days)
4. **Implement quadratic voting** - Phase 4 contract (Estimate: 4 days)
5. **Implement treasury governance** - Phase 5 contract (Estimate: 5 days)
6. **Document governance patterns** - Write comprehensive guides (Estimate: 2 days)

## Project-Specific Guidelines

### Code Style (Aiken)
- Use snake_case for function names
- Use PascalCase for type names
- Maximum function length: 50 lines
- Always add type annotations
- Document voting logic with detailed comments

### Testing Requirements
- Minimum 80% code coverage
- Unit tests for all validators
- Test voting scenarios (valid, invalid, edge cases)
- Test signature validation thoroughly
- Test time bounds and deadlines
- Property-based tests for voting logic

### Security Considerations (Governance-Specific)
- **Signature validation** - Verify all voter signatures
- **Double voting prevention** - Ensure one vote per voter
- **Time bounds enforcement** - Validate voting periods
- **Council authorization** - Check proper permissions
- **State integrity** - Validate proposal state transitions
- **Replay attack prevention** - Unique transaction identifiers

### Aiken Best Practices (Voting Contracts)
```aiken
// ✅ Good: Clear voting validation
validator simple_voting {
  fn vote(datum: VoteDatum, redeemer: VoteRedeemer, ctx: ScriptContext) -> Bool {
    let ScriptContext { transaction, purpose } = ctx

    // Validate voter signature
    let voter_signed = list.has(transaction.extra_signatories, redeemer.voter)

    // Validate voting period
    let in_voting_period = validate_time_range(datum, transaction)

    // Validate vote hasn't been cast
    let vote_not_cast = !is_duplicate_vote(datum, redeemer)

    voter_signed && in_voting_period && vote_not_cast
  }
}

// ❌ Bad: Insufficient validation
validator weak_voting {
  fn vote(d: D, r: R, c: C) -> Bool {
    True  // Insecure - anyone can vote!
  }
}
```

## Common Patterns & Examples

### Pattern: Simple Voting with Signature Validation
```aiken
// Validate single signature voting
validator simple_voting {
  fn vote(datum: VoteDatum, redeemer: VoteRedeemer, ctx: ScriptContext) -> Bool {
    let ScriptContext { transaction, purpose } = ctx

    // Check voter signature
    expect list.has(transaction.extra_signatories, redeemer.voter)

    // Check voting period
    expect validate_voting_period(datum.start_time, datum.end_time, transaction.validity_range)

    // Check vote value is valid (Yes/No)
    expect or {
      redeemer.vote == Yes,
      redeemer.vote == No,
    }

    True
  }
}
```

### Pattern: Municipal Council Multi-Sig
```aiken
// Validate multi-signature council decisions
validator municipal_council {
  fn propose(datum: CouncilDatum, redeemer: ProposalRedeemer, ctx: ScriptContext) -> Bool {
    let ScriptContext { transaction, purpose } = ctx

    // Check required number of council signatures
    let signatures = list.filter(
      datum.council_members,
      fn(member) { list.has(transaction.extra_signatories, member) }
    )

    // Require quorum (e.g., 2/3 majority)
    let quorum_met = list.length(signatures) * 3 >= list.length(datum.council_members) * 2

    // Validate proposal
    expect quorum_met
    expect validate_proposal(redeemer.proposal)

    True
  }
}
```

## Dependencies & Integration

### External Services
None - pure on-chain Aiken contracts.

### Related Branches
- **development**: Merge target (after testing complete)
- **testnet**: Deployment validation (before merging to development)
- **main**: Production (after full validation path)
- **educational**: Reference for secure patterns

### Integration Points
- Merge to development when feature complete
- Deploy to testnet for validation
- Document governance patterns for reference
- CI/CD via GitHub Actions

## Environment Variables

```bash
# Not applicable - Aiken contracts are pure on-chain code
# Deployment environment variables are in testnet branch
```

## Troubleshooting

### Common Issues

**Issue**: `aiken check` fails with type errors in voting logic
**Solution**: Review signature validation types, ensure datum/redeemer structures match.

**Issue**: `aiken test` fails for voting scenarios
**Solution**: Check test data matches contract expectations, verify signature lists are correct.

**Issue**: Voting period validation fails
**Solution**: Review time range validation, check validity_range bounds.

**Issue**: Council quorum calculation incorrect
**Solution**: Review integer math for quorum requirements, test edge cases.

**Issue**: State transition validation fails
**Solution**: Check proposal state machine, verify valid state transitions.

## Resources & References

### Internal Documentation
- **Voting Contracts**: `examples/voting-contracts/README.md`
- **Aiken Docs**: Run `aiken docs` in voting-contracts/
- **Jimmy's Workflow**: See `JIMMYS-WORKFLOW.md`

### External Resources
- **Aiken Language**: https://aiken-lang.org/
- **Aiken Tutorial**: https://aiken-lang.org/example--hello-world
- **Cardano Governance**: https://docs.cardano.org/governance/
- **Voting Systems**: Research on blockchain voting mechanisms

## Important Reminders for AI Assistants

1. **This is governance branch** - Feature development for voting contracts
2. **Use Jimmy's Workflow** for all implementation tasks
3. **Follow TDD** - Write tests before implementation
4. **Security critical** - Voting logic must be thoroughly validated
5. **Merge path** - governance → development → testnet → main
6. **Two contracts done** - simple_voting.ak and municipal_council.ak complete
7. **Update this file** as feature develops

### Branch-Specific Rules
- **On governance branch**: Voting contract feature development
- **Before merging to development**: All tests passing, security reviewed
- **Before mainnet**: Full validation path (testnet → main)
- **Quality gates**: >80% coverage, 2+ reviewer approvals
- **Security focus**: Signature validation, time bounds, state integrity

### Aiken-Specific Commands
```bash
aiken check    # Syntax and type checking
aiken test     # Run test suite
aiken build    # Compile contracts
aiken fmt      # Format code
aiken docs     # Generate documentation
```

### Voting Contract Testing
```bash
# Test simple voting
aiken test -m "simple_voting"

# Test municipal council
aiken test -m "municipal_council"

# Test all voting logic
cd examples/voting-contracts && aiken test
```

---

**This document follows the [agents.md](https://agents.md/) standard for AI coding assistants.**

**Last Updated**: 2025-10-02
**Branch**: governance
**Project**: Aiken Developer's Reference Guide
