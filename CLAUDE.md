# Claude AI Assistant Instructions

Please refer to **AGENTS.md** for complete development guidelines.

### Project: Aiken Developer's Reference Guide
- **Branch**: governance (Voting Contracts Feature Development)
- **Type**: Feature branch for voting and governance contracts
- **Status**: 60% complete (two contracts done, more planned)

### What's on This Branch
- ✅ simple_voting.ak - Complete (Phase 1)
- ✅ municipal_council.ak - Complete (Phase 2)
- ⚪ delegation_voting.ak - Planned (Phase 3)
- ⚪ quadratic_voting.ak - Planned (Phase 4)
- ⚪ treasury_governance.ak - Planned (Phase 5)

### Merge Path
```
governance → development → testnet (validate) → main (production)
```

### Commands
```bash
# Aiken validation workflow
cd examples/voting-contracts
aiken check    # Type checking
aiken test     # Run tests (>80% coverage required)
aiken build    # Compile contracts
aiken fmt      # Format code

# Test specific contracts
aiken test -m "simple_voting"
aiken test -m "municipal_council"
```

### Quality Gates
- ✅ `aiken check` passes
- ✅ `aiken test` passes with >80% coverage
- ✅ Security review completed
- 🔄 Integration tests in progress
- ⚪ Testnet deployment pending

### Security Focus
- Signature validation (multi-sig support)
- Time bounds enforcement
- Double voting prevention
- Council authorization checks
- State integrity validation

### Next Steps
1. Complete integration testing
2. Deploy to testnet for validation
3. Document governance patterns
4. Plan delegation voting implementation
5. Merge to development when stable

### Purpose
Develop secure voting and governance contracts before merging to development branch.

**Reference**: See **AGENTS.md** and **JIMMYS-WORKFLOW.md**

*Last updated: 2025-10-02 | Branch: governance*
