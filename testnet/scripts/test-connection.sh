#!/bin/bash

# Simple testnet connection test script
# Tests basic connectivity to Cardano testnets

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Test Blockfrost API connectivity
test_blockfrost() {
    local network=$1
    local url=""
    
    case $network in
        preprod)
            url="https://cardano-preprod.blockfrost.io/api/v0"
            ;;
        preview)
            url="https://cardano-preview.blockfrost.io/api/v0"
            ;;
        *)
            error "Unsupported network: $network"
            return 1
            ;;
    esac
    
    info "Testing Blockfrost API connectivity for $network..."
    
    # Test basic health endpoint (no auth required)
    if curl -s --max-time 10 "$url/health" > /dev/null; then
        success "Blockfrost $network API is reachable"
        
        # Test network info endpoint (also no auth required usually)
        local network_info=$(curl -s --max-time 10 "$url/network" 2>/dev/null || echo "{}")
        if echo "$network_info" | jq -e '.supply' > /dev/null 2>&1; then
            success "Blockfrost $network API is responding correctly"
            local supply=$(echo "$network_info" | jq -r '.supply.circulating // "unknown"')
            info "Current circulating supply: $supply"
        else
            warn "Blockfrost $network API reachable but may require authentication"
        fi
        
        return 0
    else
        error "Blockfrost $network API is unreachable"
        return 1
    fi
}

# Test cardano-cli with local node
test_cardano_cli() {
    local network=$1
    local magic=""
    
    case $network in
        preprod)
            magic="1097911063"
            ;;
        preview)
            magic="2"
            ;;
        *)
            error "Unsupported network: $network"
            return 1
            ;;
    esac
    
    info "Testing cardano-cli connectivity for $network..."
    
    # Check if cardano-cli is available
    if ! command -v cardano-cli >/dev/null 2>&1; then
        warn "cardano-cli not found in PATH"
        return 1
    fi
    
    # Check if node socket exists
    local socket_path="${CARDANO_NODE_SOCKET_PATH:-/tmp/cardano-node.socket}"
    if [[ ! -S "$socket_path" ]]; then
        warn "Cardano node socket not found at $socket_path"
        info "You can:"
        info "  1. Start a local cardano-node"
        info "  2. Connect to a remote node"
        info "  3. Use Blockfrost API instead"
        return 1
    fi
    
    # Test query tip
    if cardano-cli query tip --testnet-magic "$magic" 2>/dev/null; then
        success "cardano-cli can query $network network"
        return 0
    else
        error "cardano-cli failed to query $network network"
        return 1
    fi
}

# Test specific network
test_network() {
    local network=$1
    
    echo
    echo "========================================"
    echo "  Testing $network Network Connectivity"
    echo "========================================"
    
    local blockfrost_ok=false
    local cli_ok=false
    
    # Test Blockfrost
    if test_blockfrost "$network"; then
        blockfrost_ok=true
    fi
    
    # Test cardano-cli
    if test_cardano_cli "$network"; then
        cli_ok=true
    fi
    
    # Summary for this network
    echo
    echo "Summary for $network:"
    if $blockfrost_ok; then
        success "✓ Blockfrost API connection working"
    else
        error "✗ Blockfrost API connection failed"
    fi
    
    if $cli_ok; then
        success "✓ cardano-cli connection working"
    else
        warn "✗ cardano-cli connection not available"
    fi
    
    if $blockfrost_ok || $cli_ok; then
        success "At least one connection method available for $network"
        return 0
    else
        error "No connection methods available for $network"
        return 1
    fi
}

# Main function
main() {
    local networks=("preprod" "preview")
    
    if [[ $# -gt 0 ]]; then
        networks=("$@")
    fi
    
    echo "Cardano Testnet Connection Test"
    echo "Testing networks: ${networks[*]}"
    
    local overall_success=true
    
    for network in "${networks[@]}"; do
        if ! test_network "$network"; then
            overall_success=false
        fi
    done
    
    echo
    echo "========================================"
    echo "           OVERALL SUMMARY"
    echo "========================================"
    
    if $overall_success; then
        success "All tested networks have at least one working connection method"
        echo
        info "You can now proceed with testnet deployments!"
        info "Run: ./testnet/scripts/tracer-bullet-deploy.sh preprod hello-world cardano-cli"
    else
        warn "Some networks have connection issues"
        echo
        info "Recommendations:"
        info "1. Set up Blockfrost API keys (easiest): https://blockfrost.io"
        info "2. Or start a local cardano-node"
        info "3. Check the connection guide: ./testnet/TESTNET_CONNECTION_GUIDE.md"
    fi
    
    return $($overall_success && echo 0 || echo 1)
}

# Help function
show_help() {
    cat << EOF
Usage: $0 [NETWORK...]

Test connectivity to Cardano testnets using available methods.

NETWORKS:
    preprod    Test Preprod testnet (default)
    preview    Test Preview testnet

If no networks specified, tests both preprod and preview.

EXAMPLES:
    $0                    # Test both preprod and preview
    $0 preprod           # Test only preprod
    $0 preprod preview   # Test both explicitly

EOF
}

# Handle command line arguments
case "${1:-}" in
    -h|--help)
        show_help
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac



