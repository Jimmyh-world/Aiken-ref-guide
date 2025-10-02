# Claude AI Assistant Instructions

Please refer to **AGENTS.md** for complete development guidelines.

### Project: Aiken Developer's Reference Guide
- **Branch**: educational (Security Learning - NEVER DEPLOY)
- **Type**: Intentionally vulnerable contracts for education
- **Status**: 20% complete (content not created yet)

## ⚠️⚠️⚠️ CRITICAL WARNING ⚠️⚠️⚠️

**THIS BRANCH CONTAINS INTENTIONALLY VULNERABLE CONTRACTS**

**NEVER DEPLOY CODE FROM THIS BRANCH TO ANY NETWORK**
- ❌ NOT for testnet
- ❌ NOT for mainnet
- ❌ NOT for local testing with real value

**Purpose**: Educational demonstrations of security vulnerabilities ONLY.

### What's on This Branch
- ⚪ missing-signature-checks (NOT CREATED YET)
- ⚪ insufficient-datum-validation (NOT CREATED YET)
- ⚪ double-spending-attacks (NOT CREATED YET)
- ⚪ timing-attacks (NOT CREATED YET)
- ⚪ value-extraction (NOT CREATED YET)

### Educational Structure
Each vulnerability includes:
1. **vulnerable/** - ⚠️ NEVER DEPLOY - Intentionally broken
2. **exploits/** - How to attack it
3. **secure/** - ✅ Proper fix
4. **README.md** - Security analysis

### Commands (Analysis Only)
```bash
# Check syntax (don't deploy)
aiken check

# Run exploitation tests
aiken test -m "exploit_"

# Generate docs
aiken docs

# DO NOT BUILD FOR DEPLOYMENT
```

### Purpose
Teach Aiken security patterns through intentionally vulnerable examples. Each contract demonstrates:
- What the vulnerability is
- How it can be exploited
- How to fix it properly
- Real-world exploit examples

### Required on Every File
```aiken
/// ⚠️⚠️⚠️ NEVER DEPLOY THIS CONTRACT ⚠️⚠️⚠️
///
/// This contract is INTENTIONALLY VULNERABLE for educational purposes.
```

**Reference**: See **AGENTS.md** and **JIMMYS-WORKFLOW.md**

*Last updated: 2025-10-02 | Branch: educational | ⚠️ NEVER DEPLOY*
