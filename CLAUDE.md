# Claude AI Assistant Instructions

Please refer to **AGENTS.md** for complete development guidelines.

### Project: Aiken Developer's Reference Guide
- **Branch**: development (Latest Features & Experimental Patterns)
- **Type**: Work-in-progress Aiken smart contracts
- **Status**: 50% complete (token contracts in progress)

### What's on This Branch
- ✅ hello-world (complete reference)
- ✅ escrow-contract (ready for review)
- 🔄 token-contracts (50% - fungible token in progress)
- ⚪ voting-contracts (waiting for governance merge)

### ⚠️ CRITICAL: TESTNET ONLY
**NEVER deploy development branch to mainnet without review and promotion to main.**

### Commands
```bash
# Aiken validation workflow
aiken check    # Type checking
aiken test     # Run tests (>80% coverage required)
aiken build    # Compile contracts
aiken fmt      # Format code

# Contract-specific
cd examples/token-contracts
aiken check && aiken test && aiken build
```

### Quality Gates
- ✅ `aiken check` passes
- ✅ `aiken test` >80% coverage
- ✅ At least 1 reviewer approval
- ⚠️ **TESTNET ONLY** deployment

### Purpose
Develop and refine latest Aiken contracts before testnet validation and mainnet promotion.

**Deployment Path**: development → testnet (validate) → main (production)

**Reference**: See **AGENTS.md** and **JIMMYS-WORKFLOW.md**

*Last updated: 2025-10-02 | Branch: development*
