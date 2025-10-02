# Claude AI Assistant Instructions

Please refer to **AGENTS.md** for complete development guidelines.

### Project: Aiken Developer's Reference Guide
- **Branch**: testnet (Deployment Infrastructure)
- **Type**: Testnet deployment tooling and validation
- **Status**: 70% complete (infrastructure ready, waiting for contracts)

### What's on This Branch
- ✅ Deployment scripts (complete)
- ✅ Environment configs (preprod, preview, local)
- ✅ Testnet connection testing
- ✅ Deployment result documentation
- ⚪ Waiting for token/voting contracts from other branches

### Deployment Workflow
```bash
# 1. Check environment
./testnet/scripts/check-environment.sh

# 2. Test network connection
./testnet/scripts/test-connection.sh preprod

# 3. Deploy contract
./testnet/scripts/tracer-bullet-deploy.sh preprod [contract-name]

# 4. Monitor logs
tail -f testnet/logs/deployment-$(date +%Y%m%d).log

# 5. Check results
cat testnet/results/*.json
```

### Getting Contracts to Deploy
```bash
# From development branch
git checkout development -- examples/token-contracts/

# From governance branch
git checkout governance -- examples/voting-contracts/
```

### Networks
- **Preprod** (recommended): Most stable, closest to mainnet
- **Preview**: Faster, more experimental
- **Local**: Development only

### Quality Gates
- ✅ Contract deploys successfully
- ✅ Contract functions correctly on testnet
- ✅ No errors in logs
- ✅ Performance acceptable
- ✅ Results documented

### Purpose
Test contracts from development/governance branches before mainnet deployment.

**Deployment Path**: development/governance → testnet (validate) → main (production)

**Reference**: See **AGENTS.md** and **JIMMYS-WORKFLOW.md**

*Last updated: 2025-10-02 | Branch: testnet*
