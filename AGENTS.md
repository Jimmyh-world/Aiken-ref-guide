# Aiken Developer's Reference Guide - Educational Branch

**STATUS: EDUCATIONAL CONTENT** - Last Updated: 2025-10-02
**Branch**: educational (Security Learning - NEVER DEPLOY)
**Completion**: 20% (Intentionally vulnerable contracts for learning)

## ⚠️ CRITICAL WARNING ⚠️

**THIS BRANCH CONTAINS INTENTIONALLY VULNERABLE CONTRACTS**

**NEVER DEPLOY CODE FROM THIS BRANCH TO ANY NETWORK**
- ❌ NOT for testnet
- ❌ NOT for preprod
- ❌ NOT for preview
- ❌ NOT for mainnet
- ❌ NOT for local testing with real value

**Purpose**: Educational demonstrations of security vulnerabilities in Aiken smart contracts.

**Every contract on this branch is INTENTIONALLY BROKEN for teaching purposes.**

## Repository Information
- **GitHub Repository**: https://github.com/Jimmyh-world/Aiken-ref-guide
- **Local Directory**: `~/projects/cardano/aiken`
- **Primary Purpose**: Security education and vulnerability demonstrations

## Important Context

This branch provides **intentionally vulnerable Aiken contracts** to teach security best practices. Each contract demonstrates a specific vulnerability class with explanations of:
1. What the vulnerability is
2. How it can be exploited
3. How to fix it properly
4. Real-world examples of similar exploits

### 5-Branch Architecture

- **main**: Production-ready contracts (stable, audited, mainnet-safe)
- **development**: Latest features & experimental patterns (testnet only)
- **educational** (this branch): Security learning (NEVER DEPLOY)
- **governance**: Feature branch for voting contracts
- **testnet**: Deployment infrastructure and testing

**Purpose**: Teach Aiken security patterns through intentionally vulnerable examples.

### Integration with .cursor/rules/
This AGENTS.md **complements** .cursor/rules/, following agents.md standard.

## Core Development Principles (MODIFIED FOR EDUCATIONAL BRANCH)

### 1. SECURITY EDUCATION FIRST
- Every contract MUST have a "⚠️ NEVER DEPLOY" warning
- Document the specific vulnerability being demonstrated
- Explain how to exploit the vulnerability
- Provide the correct, secure implementation
- Include links to related security resources

### 2. ANTI-PATTERNS FOR LEARNING
- Deliberately break security best practices
- Show common mistakes developers make
- Demonstrate real-world attack vectors
- Provide exploitation scenarios
- **BUT**: Always document what's wrong and how to fix it

### 3. TDD FOR EXPLOITS
- Write tests that demonstrate the vulnerability
- Show how an attacker would exploit the contract
- Test the secure version to prove the fix works
- Document the before/after comparison

### 4. Documentation Standards (Educational)
- Always include actual dates
- Mark every file with "NEVER DEPLOY" warnings
- Use clear, factual language about vulnerabilities
- Provide references to real exploits when possible
- Document the learning objectives

### 5. Jimmy's Workflow (Modified)
**Use Red/Green checkpoints for educational content:**

- 🔴 **RED (IMPLEMENT)**: Create vulnerable contract + exploit
- 🟢 **GREEN (VALIDATE)**: Prove vulnerability is exploitable
- 🔵 **CHECKPOINT**: Document fix and security lesson

**Reference**: See **JIMMYS-WORKFLOW.md**

## Project Overview

This branch provides **security education through intentionally vulnerable Aiken contracts**. Each contract demonstrates a specific vulnerability class with exploitation examples and secure alternatives.

**Key Responsibilities:**
- Demonstrate common Aiken vulnerabilities
- Provide exploitation examples
- Teach secure coding patterns
- Document real-world attack scenarios
- Reference security resources

**Important Distinctions:**
- **Educational vs Development**: Educational is intentionally broken, development is functional
- **Educational vs Main**: Educational should NEVER be deployed, main is production-ready
- **Purpose**: Teaching tool only, not functional contracts

## Current Status - Educational Branch

⚠️ **EDUCATIONAL CONTENT** - 20% (Security tutorials NOT CREATED YET)

### Planned Vulnerability Demonstrations:
- ⚪ **missing-signature-checks/** - NOT STARTED
  - Vulnerability: No signature validation
  - Attack: Anyone can spend UTxOs
  - Fix: Proper signature verification

- ⚪ **insufficient-datum-validation/** - NOT STARTED
  - Vulnerability: Missing datum checks
  - Attack: Malformed data exploitation
  - Fix: Complete datum validation

- ⚪ **double-spending-attacks/** - NOT STARTED
  - Vulnerability: No state tracking
  - Attack: Replay attacks
  - Fix: Proper state management

- ⚪ **timing-attacks/** - NOT STARTED
  - Vulnerability: Missing time bounds
  - Attack: Transaction timing manipulation
  - Fix: Proper time range validation

- ⚪ **value-extraction/** - NOT STARTED
  - Vulnerability: Incorrect value checking
  - Attack: Drain contract funds
  - Fix: Proper value validation

### Educational Requirements:
- ⚠️ Every contract MUST have "NEVER DEPLOY" warning
- ⚠️ Every contract MUST document the vulnerability
- ⚠️ Every contract MUST provide exploitation example
- ⚠️ Every contract MUST show the secure fix
- ⚠️ Every contract MUST reference security resources

## Technology Stack

### Educational Tools
- **Language**: Aiken v1.1.15+ (for vulnerable examples)
- **Testing**: Aiken test framework (to demonstrate exploits)
- **Documentation**: Detailed security analysis
- **References**: Real-world exploit examples

### Educational Structure
- Vulnerable contract implementation
- Exploitation test suite
- Security analysis documentation
- Secure alternative implementation
- Learning objectives and takeaways

## Build & Test Commands

### ⚠️ WARNING: DO NOT DEPLOY THESE CONTRACTS ⚠️

```bash
# Educational contracts - ANALYSIS ONLY
cd examples/[vulnerability-type]

# Check syntax (but don't deploy)
aiken check

# Run tests (shows exploitation)
aiken test

# DO NOT BUILD FOR DEPLOYMENT
# aiken build  ← DO NOT USE

# Generate documentation
aiken docs
```

### Exploitation Testing
```bash
# Run exploitation tests
cd examples/missing-signature-checks
aiken test -m "exploit_"

# Compare with secure version
cd examples/missing-signature-checks/secure
aiken test
```

## Repository Structure

```
aiken/
├── examples/
│   ├── missing-signature-checks/    # ⚪ NOT CREATED YET
│   │   ├── vulnerable/
│   │   │   ├── validators/
│   │   │   │   └── no-sig-check.ak  # ⚠️ NEVER DEPLOY
│   │   │   └── aiken.toml
│   │   ├── exploits/
│   │   │   └── exploit-test.ak      # Demonstrates attack
│   │   ├── secure/
│   │   │   ├── validators/
│   │   │   │   └── with-sig-check.ak # ✅ Proper fix
│   │   │   └── aiken.toml
│   │   └── README.md                # Security analysis
│   │
│   ├── insufficient-datum-validation/ # ⚪ NOT CREATED YET
│   │   ├── vulnerable/
│   │   ├── exploits/
│   │   ├── secure/
│   │   └── README.md
│   │
│   ├── double-spending-attacks/      # ⚪ NOT CREATED YET
│   │   ├── vulnerable/
│   │   ├── exploits/
│   │   ├── secure/
│   │   └── README.md
│   │
│   ├── timing-attacks/               # ⚪ NOT CREATED YET
│   │   ├── vulnerable/
│   │   ├── exploits/
│   │   ├── secure/
│   │   └── README.md
│   │
│   └── value-extraction/             # ⚪ NOT CREATED YET
│       ├── vulnerable/
│       ├── exploits/
│       ├── secure/
│       └── README.md
│
├── docs/
│   └── security/                     # Security guides
│       ├── common-vulnerabilities.md
│       ├── secure-patterns.md
│       └── exploit-examples.md
│
├── AGENTS.md                         # This file
└── CLAUDE.md                         # Quick reference
```

## Development Workflow

### Creating Educational Content
1. **Identify vulnerability** to demonstrate
2. **Research real exploits** in similar contracts
3. **Implement vulnerable version** with clear warning
4. **Write exploitation tests** that prove the vulnerability
5. **Implement secure version** with proper fixes
6. **Document thoroughly**:
   - What the vulnerability is
   - How it can be exploited
   - Impact and severity
   - How to fix it properly
   - Real-world examples
7. **Add "NEVER DEPLOY" warnings** everywhere

### Educational Content Structure
Each vulnerability demonstration should include:

```
vulnerability-name/
├── vulnerable/           # ⚠️ NEVER DEPLOY - Broken version
│   └── validators/
│       └── broken.ak     # Intentionally vulnerable
│
├── exploits/             # How to attack it
│   └── exploit-test.ak   # Proves exploitation
│
├── secure/               # ✅ Correct implementation
│   └── validators/
│       └── secure.ak     # Proper fix
│
└── README.md             # Full security analysis
    ├── Vulnerability Description
    ├── Exploitation Scenario
    ├── Impact Assessment
    ├── Secure Implementation
    └── References
```

### Before Committing Educational Content
1. ⚠️ Add "NEVER DEPLOY" warnings to ALL files
2. Document the specific vulnerability clearly
3. Provide exploitation example
4. Show the secure fix
5. Test both vulnerable and secure versions
6. Add references to real-world exploits
7. Review documentation completeness

## Known Issues & Technical Debt

### 🔴 Critical Issues
None - this branch is intentionally non-functional.

### 🟡 Important Issues
1. **No content created yet** - All vulnerability demonstrations are planned but not implemented (2025-10-02)
2. **Need security references** - Research real-world Cardano/Plutus exploits
3. **Documentation structure** - Define standard template for vulnerability docs

### 📝 Technical Debt
1. **Create missing-signature-checks** - First vulnerability demo (Estimate: 2 days)
2. **Create datum-validation** - Second vulnerability demo (Estimate: 2 days)
3. **Create double-spending** - Third vulnerability demo (Estimate: 2 days)
4. **Create timing-attacks** - Fourth vulnerability demo (Estimate: 2 days)
5. **Create value-extraction** - Fifth vulnerability demo (Estimate: 2 days)
6. **Write security guides** - Common vulnerabilities documentation (Estimate: 3 days)

## Project-Specific Guidelines

### Educational Content Rules
1. **NEVER DEPLOY WARNING** - Required on every contract file
2. **Clear vulnerability description** - What's broken and why
3. **Exploitation demonstration** - Prove it's vulnerable
4. **Secure alternative** - Show the proper fix
5. **Real-world references** - Link to actual exploits when possible

### Warning Format (Required)
```aiken
/// ⚠️⚠️⚠️ NEVER DEPLOY THIS CONTRACT ⚠️⚠️⚠️
///
/// This contract is INTENTIONALLY VULNERABLE for educational purposes.
///
/// Vulnerability: [Name of vulnerability]
/// Impact: [What can go wrong]
/// Exploitation: See exploits/ directory
/// Fix: See secure/ directory
///
/// DO NOT USE THIS CODE IN ANY PRODUCTION OR TESTNET ENVIRONMENT
```

### Security Documentation Template
```markdown
# [Vulnerability Name]

## ⚠️ NEVER DEPLOY - Educational Only

## Overview
[Brief description of the vulnerability]

## Vulnerability Details
[Detailed explanation of what's wrong]

## Exploitation Scenario
[Step-by-step attack description]

## Impact Assessment
- Severity: [Critical/High/Medium/Low]
- Potential Loss: [Description]
- Attack Difficulty: [Easy/Medium/Hard]

## Secure Implementation
[How to fix it properly]

## References
- [Real-world exploit example]
- [Security documentation]
- [Related vulnerabilities]
```

## Common Anti-Patterns (What NOT to Do)

### Anti-Pattern: Missing Signature Check
```aiken
/// ⚠️ NEVER DEPLOY - VULNERABLE
/// Missing signature validation - anyone can spend!

validator vulnerable_escrow {
  fn spend(datum: Datum, redeemer: Redeemer, ctx: ScriptContext) -> Bool {
    // ❌ NO SIGNATURE CHECK - ANYONE CAN SPEND!
    True  // This is intentionally broken for education
  }
}
```

**Fix (Secure Version):**
```aiken
/// ✅ SECURE - Proper signature validation

validator secure_escrow {
  fn spend(datum: Datum, redeemer: Redeemer, ctx: ScriptContext) -> Bool {
    let ScriptContext { transaction, purpose } = ctx

    // ✅ Check required signature is present
    list.has(transaction.extra_signatories, datum.owner)
  }
}
```

## Dependencies & Integration

### Educational Resources
- **Cardano Security**: https://docs.cardano.org/security/
- **Plutus Security**: https://plutus.readthedocs.io/
- **Aiken Documentation**: https://aiken-lang.org/
- **Real-world Exploits**: Research and document as found

### Related Branches
- **main**: Production contracts (secure implementations)
- **development**: Latest features (compare secure patterns)
- **governance**: Feature branch (use secure patterns)
- **testnet**: Deployment infrastructure (NOT for educational)

### Integration Points
None - this branch is isolated for educational purposes only.

## Troubleshooting

### Common Issues

**Issue**: Someone tries to deploy educational contracts
**Solution**: ⚠️ STOP IMMEDIATELY. These contracts are intentionally vulnerable and should NEVER be deployed.

**Issue**: Confusion about vulnerable vs secure versions
**Solution**: Check directory structure - `vulnerable/` is broken, `secure/` is the fix.

**Issue**: Tests pass but contract is vulnerable
**Solution**: That's intentional! Tests demonstrate exploitation, not correctness.

**Issue**: Want to use educational code in production
**Solution**: ⚠️ NEVER DO THIS. Reference the `secure/` version and adapt for your needs, but test thoroughly.

## Resources & References

### Security Documentation
- **Aiken Security**: https://aiken-lang.org/
- **Cardano Exploits**: Research and document real-world cases
- **Smart Contract Security**: General blockchain security resources

### Educational Resources
- **Creating Security Demos**: Best practices for educational content
- **Vulnerability Databases**: CVE and security bulletins
- **Cardano Security Forums**: Community discussions

## Important Reminders for AI Assistants

1. **THIS BRANCH IS INTENTIONALLY VULNERABLE**
2. **NEVER REMOVE "NEVER DEPLOY" WARNINGS**
3. **Every contract must demonstrate a specific vulnerability**
4. **Always provide both vulnerable and secure versions**
5. **Document exploitation methods clearly**
6. **Reference real-world exploits when possible**
7. **Update this file** as educational content is created

### Branch-Specific Rules
- **Educational branch**: Teaching tool, not functional contracts
- **Every file needs warnings**: "⚠️ NEVER DEPLOY"
- **Show vulnerability + fix**: Both versions required
- **Test exploitation**: Prove the vulnerability exists
- **Never deploy**: Not to testnet, not to mainnet, not anywhere with value

### Educational Content Checklist
```
✅ "NEVER DEPLOY" warning in every file
✅ Vulnerability clearly documented
✅ Exploitation example provided
✅ Secure fix demonstrated
✅ Real-world references included
✅ Learning objectives stated
✅ Impact assessment documented
```

---

**This document follows the [agents.md](https://agents.md/) standard for AI coding assistants.**

**⚠️ WARNING: This branch contains intentionally vulnerable code for educational purposes. NEVER DEPLOY. ⚠️**

**Last Updated**: 2025-10-02
**Branch**: educational
**Project**: Aiken Developer's Reference Guide
