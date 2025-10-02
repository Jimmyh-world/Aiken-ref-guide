# Aiken Developer's Reference Guide - Testnet Branch

**STATUS: INFRASTRUCTURE COMPLETE** - Last Updated: 2025-10-02
**Branch**: testnet (Deployment Infrastructure & Testing)
**Completion**: 70% (Infrastructure done, waiting for content from other branches)

## Repository Information
- **GitHub Repository**: https://github.com/Jimmyh-world/Aiken-ref-guide
- **Local Directory**: `~/projects/cardano/aiken`
- **Primary Purpose**: Testnet deployment infrastructure and contract testing

## Important Context

This branch provides **testnet deployment infrastructure** for testing Aiken smart contracts before mainnet deployment. Contains scripts, configs, and deployment tooling.

### 5-Branch Architecture

- **main**: Production-ready contracts
- **development**: Latest features (deploy here first)
- **educational**: Security learning (NEVER deploy)
- **governance**: Feature development
- **testnet** (this branch): Deployment infrastructure and testing

**Purpose**: Test contracts from development/governance branches before promoting to main.

### Integration with .cursor/rules/
This AGENTS.md **complements** .cursor/rules/, following agents.md standard.

## Core Development Principles
1-6. Standard: KISS, TDD, SOC, DRY, Documentation Standards, Jimmy's Workflow

**Reference**: See **JIMMYS-WORKFLOW.md**

## Project Overview

This branch provides **testnet deployment tooling** for Cardano (Preprod/Preview networks). Use this to validate contracts before mainnet.

**Key Responsibilities:**
- Testnet deployment scripts
- Environment configurations
- Connection testing
- Deployment validation
- Result documentation

## Current Status - Testnet Branch

✅ **INFRASTRUCTURE COMPLETE** - 70% (Tooling done, waiting for contracts)

### Infrastructure Status:
- ✅ **testnet/** directory - Complete deployment infrastructure
  - ✅ configs/ (local.env, preprod.env, preview.env)
  - ✅ scripts/ (check-environment.sh, test-connection.sh, tracer-bullet-deploy.sh)
  - ✅ results/ (deployment test results from Aug 30, 2025)
  - ✅ logs/ (empty, ready for use)
  - ✅ TESTNET_CONNECTION_GUIDE.md

### Examples on This Branch:
- ✅ **hello-world/** - Can deploy to testnet
- ✅ **escrow-contract/** - Can deploy to testnet
- ⚪ **token-contracts/** - Empty (waiting for development branch)
- ⚪ **voting-contracts/** - Empty (waiting for governance branch merge)

### Deployment History:
- Last deployment tests: August 30, 2025
- Networks tested: Preprod, Preview
- Contracts deployed: hello-world, escrow-contract

## Technology Stack

### Deployment Infrastructure
- **Networks**: Cardano Preprod, Preview, Local
- **Tooling**: Bash scripts, cardano-cli integration
- **Configuration**: Environment-specific configs
- **Testing**: Tracer bullet deployments

## Build & Test Commands

### Testnet Deployment
```bash
# Check environment setup
./testnet/scripts/check-environment.sh

# Test network connection
./testnet/scripts/test-connection.sh preprod

# Deploy contract (tracer bullet)
./testnet/scripts/tracer-bullet-deploy.sh preprod hello-world

# View deployment logs
tail -f testnet/logs/deployment-$(date +%Y%m%d).log

# Check deployment results
cat testnet/results/deployment-results-*.json
```

### Environment Configuration
```bash
# Use preprod testnet
source testnet/configs/preprod.env

# Use preview testnet
source testnet/configs/preview.env

# Use local testnet
source testnet/configs/local.env
```

### Multi-Branch Operations
```bash
git checkout testnet      # This branch (infrastructure)
git checkout development  # Get contracts to deploy
git checkout main         # Production (after testnet validation)
```

## Repository Structure

```
aiken/
├── examples/
│   ├── hello-world/            # ✅ Deployable
│   ├── escrow-contract/        # ✅ Deployable
│   ├── token-contracts/        # ⚪ Waiting for development
│   └── voting-contracts/       # ⚪ Waiting for governance
│
├── testnet/                    # ✅ INFRASTRUCTURE COMPLETE
│   ├── configs/
│   │   ├── local.env           # Local testnet config
│   │   ├── preprod.env         # Preprod testnet config
│   │   └── preview.env         # Preview testnet config
│   ├── scripts/
│   │   ├── check-environment.sh      # Verify setup
│   │   ├── test-connection.sh        # Test network connectivity
│   │   └── tracer-bullet-deploy.sh   # Deploy contracts
│   ├── results/
│   │   ├── connectivity-test-results-*.json
│   │   ├── escrow-deployment-results-*.json
│   │   └── tracer-bullet-preprod-*.json
│   ├── logs/                   # Deployment logs (empty)
│   └── TESTNET_CONNECTION_GUIDE.md
│
├── docs/                       # Same as main
├── AGENTS.md                   # This file
└── CLAUDE.md                   # Quick reference
```

## Development Workflow

### Deploying to Testnet
1. Confirm on testnet branch
2. **Get contract from development**: `git checkout development -- examples/[contract]/`
3. **Check environment**: `./testnet/scripts/check-environment.sh`
4. **Test connection**: `./testnet/scripts/test-connection.sh preprod`
5. **Deploy contract**: `./testnet/scripts/tracer-bullet-deploy.sh preprod [contract]`
6. **Verify deployment**: Check results/ and logs/
7. **Document results**: Update results/ with findings

### Before Promoting to Main
1. **Deploy to testnet** using scripts above
2. **Validate functionality** on testnet
3. **Document results** in results/
4. **Security review** of testnet behavior
5. **PR to main** if testnet validation successful

### Quality Gates
- ✅ Contract deploys successfully
- ✅ Contract functions correctly on testnet
- ✅ No unexpected errors in logs
- ✅ Performance acceptable
- ✅ Results documented

## Known Issues & Technical Debt

### 🔴 Critical Issues
None blocking testnet operations.

### 🟡 Important Issues
1. **Deployment results outdated** - Last tests Aug 30, 2025
2. **No token contract deployments** - Waiting for development branch
3. **No voting contract deployments** - Waiting for governance branch

### 📝 Technical Debt
1. **Update deployment results** - Re-run testnet validations (Estimate: 1 day)
2. **Deploy token contracts** - When available from development (Estimate: Wait for dev branch)
3. **Deploy voting contracts** - When available from governance (Estimate: Wait for governance merge)

## Project-Specific Guidelines

### Testnet Best Practices
- **Always test on preprod first** before preview
- **Document all deployments** in results/
- **Save deployment logs** in logs/
- **Use environment configs** don't hardcode
- **Validate before mainnet** - testnet success required

### Network Selection
```bash
# Preprod - Most stable, closest to mainnet
source testnet/configs/preprod.env

# Preview - Faster, more experimental
source testnet/configs/preview.env

# Local - Development only
source testnet/configs/local.env
```

## Common Patterns

### Pattern: Tracer Bullet Deployment
```bash
# 1. Setup environment
source testnet/configs/preprod.env

# 2. Build contract
cd examples/hello-world
aiken build

# 3. Deploy
cd ../../
./testnet/scripts/tracer-bullet-deploy.sh preprod hello-world

# 4. Verify
cat testnet/results/tracer-bullet-preprod-hello-world-$(date +%Y%m%d).json
```

## Dependencies & Integration

### Required Tools
- Aiken CLI (v1.1.15+)
- cardano-cli (for testnet interaction)
- Bash (for deployment scripts)
- jq (for JSON processing)

### Network Access
- **Preprod**: Public Cardano testnet
- **Preview**: Public Cardano testnet
- **Local**: Requires local Cardano node

## Troubleshooting

**Issue**: Deployment script fails
**Solution**: Run `./testnet/scripts/check-environment.sh` to verify setup.

**Issue**: Network connection timeout
**Solution**: Run `./testnet/scripts/test-connection.sh [network]` to test connectivity.

**Issue**: No contracts to deploy
**Solution**: Get contracts from development/governance branches first.

**Issue**: Outdated deployment results
**Solution**: Re-run deployments and update results/ directory with current findings.

## Resources & References

### Internal Documentation
- **Testnet Guide**: `testnet/TESTNET_CONNECTION_GUIDE.md`
- **Deployment Scripts**: `testnet/scripts/`
- **Integration Guide**: `docs/integration/deployment.md`

### External Resources
- **Cardano Testnet**: https://docs.cardano.org/cardano-testnets/
- **Aiken Deployment**: https://aiken-lang.org/

## Important Reminders for AI Assistants

1. **This is testnet branch** - Deployment infrastructure
2. **Use Jimmy's Workflow** for deployments
3. **Test before mainnet** - All contracts must pass testnet validation
4. **Document deployments** - Save results and logs
5. **Environment configs** - Use provided configs, don't hardcode
6. **Update this file** as infrastructure evolves

### Branch-Specific Rules
- **On testnet branch**: Deploy and validate contracts
- **Before mainnet**: Must pass testnet validation
- **Get contracts from**: development/governance branches
- **Never deploy**: educational branch code

---

**This document follows the [agents.md](https://agents.md/) standard for AI coding assistants.**

**Last Updated**: 2025-10-02
**Branch**: testnet
**Project**: Aiken Developer's Reference Guide
