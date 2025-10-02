# Aiken Developer's Reference Guide - Testnet Branch

**STATUS: INFRASTRUCTURE COMPLETE** - Last Updated: 2025-10-02
**Branch**: testnet (Deployment Infrastructure & Testing)
**Completion**: 70% (Infrastructure done, waiting for content from other branches)

## Repository Information
- **GitHub Repository**: https://github.com/Jimmyh-world/Aiken-ref-guide
- **Local Directory**: `~/projects/cardano/aiken`
- **Primary Purpose**: Testnet deployment infrastructure and contract testing

## Important Context

This branch provides **testnet deployment infrastructure** for testing Aiken smart contracts before mainnet deployment. Contains scripts, configs, and deployment tooling for Cardano Preprod and Preview networks.

### 5-Branch Architecture

- **main**: Production-ready contracts (stable, audited, mainnet-safe)
- **development**: Latest features & experimental patterns (deploy here first)
- **educational**: Security learning (NEVER deploy - intentionally vulnerable)
- **governance**: Voting contracts feature development
- **testnet** (this branch): Deployment infrastructure and testing

**Purpose**: Test contracts from development/governance branches before promoting to main.

**Deployment Path**: development/governance → testnet (validate) → main (production)

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
**MANDATORY for all deployment tasks**

Use the Red/Green/Blue checkpoint system to prevent AI hallucination and ensure robust deployment:

- 🔴 **RED (IMPLEMENT)**: Deploy contract, execute scripts
- 🟢 **GREEN (VALIDATE)**: Verify deployment, check testnet
- 🔵 **CHECKPOINT**: Document results, save logs

**Critical Rules:**
- NEVER skip validation phases
- NEVER proceed to next checkpoint without GREEN passing
- ALWAYS document deployment results
- ALWAYS save deployment logs

**Reference**: See **JIMMYS-WORKFLOW.md** for complete workflow system, templates, and patterns

**Usage**: When working with AI assistants, say: *"Let's use Jimmy's Workflow to execute this deployment"*

**Benefits:**
- Prevents "AI says deployed ≠ Actually deployed" problem
- Forces validation at every deployment step
- Enables safe testnet validation
- Provides clear rollback paths
- Documents deployment history

## Project Overview

This branch provides **testnet deployment tooling** for Cardano (Preprod/Preview networks). Use this to validate contracts before mainnet deployment.

**Key Responsibilities:**
- Testnet deployment scripts
- Environment configurations (preprod, preview, local)
- Connection testing
- Deployment validation
- Result documentation and logging

**Important Distinctions:**
- **Testnet vs Development**: Testnet validates, development creates
- **Testnet vs Main**: Testnet is for testing, main is production
- **Infrastructure Branch**: Focus on deployment tooling, not contract development

## Current Status - Testnet Branch

✅ **INFRASTRUCTURE COMPLETE** - 70% (Tooling done, waiting for contracts)

### Infrastructure Status:
- ✅ **testnet/** directory - Complete deployment infrastructure
  - ✅ configs/ (local.env, preprod.env, preview.env)
  - ✅ scripts/ (check-environment.sh, test-connection.sh, tracer-bullet-deploy.sh)
  - ✅ results/ (deployment test results from Aug 30, 2025)
  - ✅ logs/ (empty, ready for use)
  - ✅ TESTNET_CONNECTION_GUIDE.md

### Examples Available for Deployment:
- ✅ **hello-world/** - Can deploy to testnet
- ✅ **escrow-contract/** - Can deploy to testnet
- ⚪ **token-contracts/** - Waiting for development branch (50% complete)
- ⚪ **voting-contracts/** - Waiting for governance branch merge (60% complete)

### Deployment History:
- **Last deployment tests**: August 30, 2025
- **Networks tested**: Preprod, Preview
- **Contracts deployed**: hello-world, escrow-contract
- **Status**: Infrastructure validated, ready for new deployments

### Next Steps:
1. Deploy token contracts from development branch when ready
2. Deploy voting contracts from governance branch after merge
3. Update deployment results documentation
4. Validate all contracts on testnet before mainnet promotion

## Technology Stack

### Deployment Infrastructure
- **Networks**: Cardano Preprod, Preview, Local
- **Tooling**: Bash scripts, cardano-cli integration
- **Configuration**: Environment-specific configs
- **Testing**: Tracer bullet deployments
- **Logging**: Deployment logs and results

### Network Information
- **Preprod**: Most stable testnet, closest to mainnet behavior
- **Preview**: Faster testnet, more experimental features
- **Local**: Development-only local node

## Build & Test Commands

### Testnet Deployment Workflow
```bash
# 1. Check environment setup
./testnet/scripts/check-environment.sh

# 2. Test network connection
./testnet/scripts/test-connection.sh preprod

# 3. Deploy contract (tracer bullet)
./testnet/scripts/tracer-bullet-deploy.sh preprod hello-world

# 4. View deployment logs
tail -f testnet/logs/deployment-$(date +%Y%m%d).log

# 5. Check deployment results
cat testnet/results/deployment-results-*.json
```

### Environment Configuration
```bash
# Use preprod testnet (recommended)
source testnet/configs/preprod.env

# Use preview testnet
source testnet/configs/preview.env

# Use local testnet (development only)
source testnet/configs/local.env
```

### Contract Build Before Deployment
```bash
# Build contract on development/governance branch first
cd examples/[contract-name]
aiken check
aiken test
aiken build

# Then switch to testnet branch
git checkout testnet

# Copy contract if needed
git checkout development -- examples/[contract-name]/

# Deploy
./testnet/scripts/tracer-bullet-deploy.sh preprod [contract-name]
```

### Multi-Branch Operations
```bash
git checkout testnet      # This branch (infrastructure)
git checkout development  # Get contracts to deploy
git checkout governance   # Get voting contracts
git checkout main         # Production (after testnet validation)
```

## Repository Structure

```
aiken/
├── examples/
│   ├── hello-world/            # ✅ Deployable to testnet
│   ├── escrow-contract/        # ✅ Deployable to testnet
│   ├── token-contracts/        # ⚪ Waiting for development (50%)
│   └── voting-contracts/       # ⚪ Waiting for governance (60%)
│
├── testnet/                    # ✅ INFRASTRUCTURE COMPLETE
│   ├── configs/
│   │   ├── local.env           # Local testnet config
│   │   ├── preprod.env         # Preprod testnet config
│   │   └── preview.env         # Preview testnet config
│   │
│   ├── scripts/
│   │   ├── check-environment.sh      # Verify setup
│   │   ├── test-connection.sh        # Test network connectivity
│   │   └── tracer-bullet-deploy.sh   # Deploy contracts
│   │
│   ├── results/
│   │   ├── connectivity-test-results-*.json
│   │   ├── escrow-deployment-results-*.json
│   │   └── tracer-bullet-preprod-*.json
│   │
│   ├── logs/                   # Deployment logs (empty, ready)
│   └── TESTNET_CONNECTION_GUIDE.md
│
├── docs/                       # Documentation
├── AGENTS.md                   # This file
└── CLAUDE.md                   # Quick reference
```

## Development Workflow

### Deploying Contract to Testnet
1. **Confirm on testnet branch**: `git checkout testnet`
2. **Get contract from source branch**:
   ```bash
   # From development
   git checkout development -- examples/token-contracts/

   # From governance
   git checkout governance -- examples/voting-contracts/
   ```
3. **Check environment**: `./testnet/scripts/check-environment.sh`
4. **Test connection**: `./testnet/scripts/test-connection.sh preprod`
5. **Deploy contract**: `./testnet/scripts/tracer-bullet-deploy.sh preprod [contract]`
6. **Verify deployment**:
   - Check results/: Deployment status
   - Check logs/: Detailed logs
   - Verify on Cardano explorer
7. **Document results**: Update results/ with findings

### Before Promoting to Main
1. **Deploy to testnet** using scripts above
2. **Validate functionality** on testnet
   - Test all contract operations
   - Verify expected behavior
   - Check edge cases
3. **Document results** in results/ directory
4. **Security review** of testnet behavior
5. **Performance assessment**
6. **Create PR to main** if testnet validation successful

### Quality Gates (Testnet Validation)
- ✅ Contract deploys successfully
- ✅ Contract functions correctly on testnet
- ✅ No unexpected errors in logs
- ✅ Performance acceptable
- ✅ Security validation passed
- ✅ Results documented in results/
- ✅ At least 2 reviewer approvals

## Known Issues & Technical Debt

### 🔴 Critical Issues
None blocking testnet operations.

### 🟡 Important Issues
1. **Deployment results outdated** - Last tests Aug 30, 2025 (2025-10-02)
2. **No token contract deployments** - Waiting for development branch completion
3. **No voting contract deployments** - Waiting for governance branch merge
4. **Documentation could be expanded** - Add more deployment examples

### 📝 Technical Debt
1. **Update deployment results** - Re-run testnet validations (Estimate: 1 day)
2. **Deploy token contracts** - When available from development (Estimate: Wait for dev)
3. **Deploy voting contracts** - When available from governance (Estimate: Wait for merge)
4. **Expand deployment docs** - Add more examples and troubleshooting (Estimate: 2 days)
5. **Automate deployment testing** - CI/CD integration (Estimate: 3 days)

## Project-Specific Guidelines

### Testnet Best Practices
- **Always test on preprod first** before preview
- **Document all deployments** in results/
- **Save deployment logs** in logs/
- **Use environment configs** don't hardcode values
- **Validate before mainnet** - testnet success required for main promotion
- **Test thoroughly** - All contract operations must work

### Network Selection Guide
```bash
# Preprod - RECOMMENDED
# - Most stable testnet
# - Closest to mainnet behavior
# - Use for final validation
source testnet/configs/preprod.env

# Preview
# - Faster testnet
# - More experimental
# - Use for quick testing
source testnet/configs/preview.env

# Local
# - Development only
# - Requires local node
# - Use for initial testing
source testnet/configs/local.env
```

### Deployment Checklist
```
Before deployment:
✅ Contract built successfully (aiken build)
✅ All tests passing (aiken test)
✅ Environment configured
✅ Network connection tested

During deployment:
✅ Run deployment script
✅ Monitor logs in real-time
✅ Capture deployment output

After deployment:
✅ Verify deployment in results/
✅ Test contract operations
✅ Document findings
✅ Save logs for reference
```

## Common Patterns & Examples

### Pattern: Tracer Bullet Deployment
```bash
# 1. Setup environment
source testnet/configs/preprod.env

# 2. Verify setup
./testnet/scripts/check-environment.sh

# 3. Test connection
./testnet/scripts/test-connection.sh preprod

# 4. Build contract
cd examples/hello-world
aiken build

# 5. Deploy
cd ../../
./testnet/scripts/tracer-bullet-deploy.sh preprod hello-world

# 6. Verify
cat testnet/results/tracer-bullet-preprod-hello-world-$(date +%Y%m%d).json

# 7. Test operations
# [Manual testing on testnet]

# 8. Document
# Update results/ with findings
```

### Pattern: Multi-Contract Deployment
```bash
# Deploy multiple contracts for integration testing
for contract in hello-world escrow-contract token-contracts; do
  echo "Deploying $contract..."
  ./testnet/scripts/tracer-bullet-deploy.sh preprod $contract
  sleep 60  # Wait between deployments
done

# Verify all deployments
ls -lah testnet/results/
```

## Dependencies & Integration

### Required Tools
- **Aiken CLI** (v1.1.15+) - Contract compilation
- **cardano-cli** - Testnet interaction
- **Bash** - Deployment scripts
- **jq** - JSON processing
- **curl** - Network testing

### Network Access
- **Preprod**: Public Cardano testnet (https://preprod.cardano.org)
- **Preview**: Public Cardano testnet (https://preview.cardano.org)
- **Local**: Requires local Cardano node setup

### Related Branches
- **development**: Source for token contracts
- **governance**: Source for voting contracts
- **main**: Promotion target (after testnet validation)
- **educational**: Never deploy (intentionally vulnerable)

### Integration Points
- Get contracts from development/governance branches
- Deploy to testnet for validation
- Document results for main promotion
- CI/CD via GitHub Actions (planned)

## Environment Variables

```bash
# Environment-specific configurations in testnet/configs/

# Preprod testnet
source testnet/configs/preprod.env
# Sets: CARDANO_NODE_SOCKET_PATH, NETWORK_ID, etc.

# Preview testnet
source testnet/configs/preview.env
# Sets: CARDANO_NODE_SOCKET_PATH, NETWORK_ID, etc.

# Local testnet
source testnet/configs/local.env
# Sets: CARDANO_NODE_SOCKET_PATH, NETWORK_ID, etc.
```

## Troubleshooting

### Common Issues

**Issue**: Deployment script fails with "command not found"
**Solution**: Run `./testnet/scripts/check-environment.sh` to verify all required tools are installed.

**Issue**: Network connection timeout
**Solution**: Run `./testnet/scripts/test-connection.sh [network]` to test connectivity. Check network status at https://cardano.org/testnets.

**Issue**: No contracts to deploy
**Solution**: Get contracts from development/governance branches first using `git checkout development -- examples/[contract]/`

**Issue**: Outdated deployment results
**Solution**: Re-run deployments and update results/ directory with current findings.

**Issue**: Contract deploys but doesn't work
**Solution**: Review contract tests on source branch. Check logs/ for detailed error messages. Test contract operations manually.

**Issue**: Can't find deployment logs
**Solution**: Check testnet/logs/ directory. Logs are named by date: `deployment-YYYYMMDD.log`

## Resources & References

### Internal Documentation
- **Testnet Guide**: `testnet/TESTNET_CONNECTION_GUIDE.md`
- **Deployment Scripts**: `testnet/scripts/`
- **Deployment Results**: `testnet/results/`
- **Jimmy's Workflow**: `JIMMYS-WORKFLOW.md`

### External Resources
- **Cardano Testnet**: https://docs.cardano.org/cardano-testnets/
- **Preprod Explorer**: https://preprod.cardanoscan.io/
- **Preview Explorer**: https://preview.cardanoscan.io/
- **Aiken Deployment**: https://aiken-lang.org/

### Network Status
- **Cardano Status**: https://cardano.org/testnets
- **Network Health**: Check via test-connection.sh script

## Important Reminders for AI Assistants

1. **This is testnet branch** - Deployment infrastructure and validation
2. **Use Jimmy's Workflow** for all deployment tasks
3. **Test before mainnet** - All contracts must pass testnet validation
4. **Document deployments** - Save results and logs
5. **Environment configs** - Use provided configs, don't hardcode
6. **Update this file** as infrastructure evolves
7. **Preprod first** - Always test on preprod before preview

### Branch-Specific Rules
- **On testnet branch**: Deploy and validate contracts
- **Before mainnet**: Must pass testnet validation successfully
- **Get contracts from**: development/governance branches
- **Never deploy**: educational branch code (intentionally vulnerable)
- **Quality gates**: Successful deployment, functional testing, documentation

### Deployment Commands
```bash
# Essential testnet workflow
./testnet/scripts/check-environment.sh           # Verify setup
./testnet/scripts/test-connection.sh preprod     # Test network
./testnet/scripts/tracer-bullet-deploy.sh preprod [contract]  # Deploy

# Monitoring
tail -f testnet/logs/deployment-$(date +%Y%m%d).log
cat testnet/results/*.json
```

---

**This document follows the [agents.md](https://agents.md/) standard for AI coding assistants.**

**Last Updated**: 2025-10-02
**Branch**: testnet
**Project**: Aiken Developer's Reference Guide
