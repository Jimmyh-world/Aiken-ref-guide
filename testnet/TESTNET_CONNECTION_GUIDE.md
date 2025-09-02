# Testnet Connection Methods for Aiken Deployment

## Overview

Our tracer bullet deployment strategy tests multiple connection methods to Cardano testnets. This ensures we can validate different deployment scenarios and identify the most reliable approaches.

## Connection Methods

### 1. 🌐 Blockfrost API (Recommended for Development)

**How it works:**

- Uses Blockfrost's hosted API endpoints
- No local node required
- Best for rapid development and testing
- Supports multiple testnets (Preprod, Preview)

**Setup:**

```bash
# Get free API key from https://blockfrost.io
export BLOCKFROST_PROJECT_ID="preprod_your_project_id_here"
export BLOCKFROST_URL="https://cardano-preprod.blockfrost.io/api/v0"
```

**Pros:**

- ✅ No infrastructure setup
- ✅ Reliable uptime
- ✅ Fast setup
- ✅ Multiple network support

**Cons:**

- ❌ API rate limits
- ❌ External dependency
- ❌ Requires internet connection

### 2. 🏠 Local Cardano Node

**How it works:**

- Run your own cardano-node locally
- Direct connection to Cardano network
- Full control over synchronization and queries

**Setup:**

```bash
# Download node from https://github.com/input-output-hk/cardano-node
# Configure for testnet
cardano-node run \
  --config config.json \
  --topology topology.json \
  --database-path db/ \
  --socket-path /tmp/cardano-node.socket \
  --port 3001
```

**Pros:**

- ✅ No external dependencies
- ✅ Full control
- ✅ No rate limits
- ✅ Can work offline (once synced)

**Cons:**

- ❌ Requires setup and maintenance
- ❌ Long initial sync time
- ❌ Disk space requirements
- ❌ Continuous operation needed

### 3. 🌉 Remote Node Connection

**How it works:**

- Connect to a remote cardano-node
- Could be community-run or enterprise
- Uses direct socket connection

**Setup:**

```bash
# Point to remote node socket
export CARDANO_NODE_SOCKET_PATH="/path/to/remote/socket"
# or use SSH tunnel
ssh -L 3001:localhost:3001 user@remote-node-host
```

**Pros:**

- ✅ No local sync required
- ✅ Shared infrastructure costs
- ✅ Usually well-maintained

**Cons:**

- ❌ Network dependency
- ❌ Trust in remote operator
- ❌ Potential connectivity issues

## Our Testnet Strategy

### Phase 1: Quick Validation (Blockfrost)

```bash
# Test basic connectivity and deployment
./testnet/scripts/tracer-bullet-deploy.sh preprod hello-world cardano-cli
```

### Phase 2: Comprehensive Testing (Multiple Methods)

```bash
# Test all deployment methods
./testnet/scripts/tracer-bullet-deploy.sh preprod hello-world all
```

### Phase 3: Network Comparison

```bash
# Test same contract on different networks
./testnet/scripts/tracer-bullet-deploy.sh preprod hello-world cardano-cli
./testnet/scripts/tracer-bullet-deploy.sh preview hello-world cardano-cli
```

## Network Configurations

### Preprod Testnet (Recommended)

- **Purpose:** Pre-production testing, stable environment
- **Magic:** 1097911063
- **Blockfrost:** `https://cardano-preprod.blockfrost.io/api/v0`
- **Faucet:** [Preprod Faucet](https://docs.cardano.org/cardano-testnet/tools/faucet)

### Preview Testnet

- **Purpose:** Preview of upcoming features
- **Magic:** 2
- **Blockfrost:** `https://cardano-preview.blockfrost.io/api/v0`
- **Faucet:** [Preview Faucet](https://docs.cardano.org/cardano-testnet/tools/faucet)

### Local Testnet (Development)

- **Purpose:** Private development and testing
- **Magic:** 42 (configurable)
- **Benefits:** Complete control, fast transactions

## Connection Testing Workflow

### 1. Environment Check

```bash
# Run comprehensive environment validation
./testnet/scripts/check-environment.sh preprod hello-world
```

### 2. Basic Connectivity Test

```bash
# Test network connectivity
curl -s https://cardano-preprod.blockfrost.io/api/v0/health
```

### 3. Deployment Test

```bash
# Single method test
./testnet/scripts/tracer-bullet-deploy.sh preprod hello-world cardano-cli

# All methods test
./testnet/scripts/tracer-bullet-deploy.sh preprod hello-world all
```

## Tool-Specific Connection Methods

### Cardano CLI

- **Preferred:** Local node socket
- **Alternative:** Remote node via SSH tunnel
- **Configuration:** `--testnet-magic` and `CARDANO_NODE_SOCKET_PATH`

### Mesh (TypeScript/JavaScript)

- **Preferred:** Blockfrost API
- **Alternative:** Local node via backend proxy
- **Configuration:** Blockfrost project ID and endpoint URL

### PyCardano (Python)

- **Preferred:** Blockfrost API
- **Alternative:** Local node via socket connection
- **Configuration:** Blockfrost credentials or node socket path

## Troubleshooting Connection Issues

### Common Issues and Solutions

#### 1. Blockfrost API Issues

```bash
# Test API key
curl -H "project_id: YOUR_PROJECT_ID" \
  https://cardano-preprod.blockfrost.io/api/v0/health

# Check rate limits
curl -H "project_id: YOUR_PROJECT_ID" \
  https://cardano-preprod.blockfrost.io/api/v0/accounts/usage
```

#### 2. Local Node Issues

```bash
# Check node socket
ls -la /tmp/cardano-node.socket

# Check node status
cardano-cli query tip --testnet-magic 1097911063
```

#### 3. Network Connectivity

```bash
# Test network reachability
ping cardano-preprod.blockfrost.io

# Check DNS resolution
nslookup cardano-preprod.blockfrost.io
```

## Security Considerations

### API Key Management

- ✅ Use environment variables, never hardcode
- ✅ Use different keys for different environments
- ✅ Rotate keys regularly
- ✅ Monitor usage for anomalies

### Network Security

- ✅ Use HTTPS for all API calls
- ✅ Validate SSL certificates
- ✅ Consider VPN for sensitive operations
- ✅ Log all network operations

### Wallet Security

- ✅ Use dedicated testnet wallets
- ✅ Never use mainnet keys on testnet
- ✅ Generate new keys for each test cycle
- ✅ Store keys securely

## Monitoring and Logging

### Connection Health Monitoring

```bash
# Automated health checks
while true; do
  if curl -s --max-time 5 \
    https://cardano-preprod.blockfrost.io/api/v0/health > /dev/null; then
    echo "$(date): Preprod API healthy"
  else
    echo "$(date): Preprod API unhealthy"
  fi
  sleep 60
done
```

### Performance Monitoring

- Track API response times
- Monitor transaction confirmation times
- Log deployment success rates
- Measure script execution costs

## Next Steps

1. **Set up Blockfrost account** and get API keys
2. **Configure environment files** with your credentials
3. **Run environment check** script
4. **Execute tracer bullet deployment** on preprod
5. **Compare results** across different methods
6. **Document findings** and optimize configurations

## Resources

- [Cardano Testnet Documentation](https://docs.cardano.org/cardano-testnet/)
- [Blockfrost API Documentation](https://docs.blockfrost.io/)
- [Cardano Node Setup Guide](https://github.com/input-output-hk/cardano-node)
- [Aiken Documentation](https://aiken-lang.org/)



