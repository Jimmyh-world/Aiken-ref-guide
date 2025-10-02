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

### Commands
```bash
./testnet/scripts/check-environment.sh
./testnet/scripts/test-connection.sh preprod
./testnet/scripts/tracer-bullet-deploy.sh preprod hello-world
cat testnet/results/*.json
```

### Purpose
Test contracts from development/governance branches before mainnet deployment.

**Reference**: See **AGENTS.md** and **JIMMYS-WORKFLOW.md**

*Last updated: 2025-10-02 | Branch: testnet*
