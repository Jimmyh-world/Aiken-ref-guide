#!/bin/bash

# Environment Check Script for Testnet Deployments
# Validates that all required tools and configurations are available

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging
info() { echo -e "${BLUE}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }

# Check functions
check_command() {
    local cmd=$1
    local version_flag=${2:-"--version"}
    
    if command -v "$cmd" >/dev/null 2>&1; then
        local version_output=$($cmd $version_flag 2>&1 | head -1 || echo "Version info unavailable")
        success "$cmd is installed: $version_output"
        return 0
    else
        error "$cmd is not installed or not in PATH"
        return 1
    fi
}

check_node_socket() {
    local socket_path=${1:-"/tmp/cardano-node.socket"}
    
    if [[ -S "$socket_path" ]]; then
        success "Cardano node socket found at $socket_path"
        return 0
    else
        warn "Cardano node socket not found at $socket_path"
        info "You may need to start a local cardano-node or connect to a remote one"
        return 1
    fi
}

check_network_connectivity() {
    local network=$1
    
    case $network in
        preprod)
            local test_url="https://cardano-preprod.blockfrost.io/api/v0/health"
            ;;
        preview)
            local test_url="https://cardano-preview.blockfrost.io/api/v0/health"
            ;;
        *)
            info "Skipping network connectivity check for $network"
            return 0
            ;;
    esac
    
    if curl -s --max-time 10 "$test_url" >/dev/null; then
        success "$network network is accessible"
        return 0
    else
        warn "$network network connectivity test failed"
        return 1
    fi
}

check_blockfrost_config() {
    local network=$1
    local config_file="$2"
    
    if [[ -f "$config_file" ]]; then
        source "$config_file"
        if [[ -n "${BLOCKFROST_PROJECT_ID:-}" && "$BLOCKFROST_PROJECT_ID" != *"your_project_id_here" ]]; then
            success "Blockfrost configuration appears valid"
            return 0
        else
            warn "Blockfrost project ID not configured in $config_file"
            return 1
        fi
    else
        error "Configuration file not found: $config_file"
        return 1
    fi
}

check_aiken_project() {
    local project_dir=$1
    
    if [[ -f "$project_dir/aiken.toml" ]]; then
        success "Valid Aiken project found at $project_dir"
        
        # Check if already compiled
        if [[ -f "$project_dir/plutus.json" ]]; then
            info "Found existing plutus.json - project appears compiled"
        else
            warn "No plutus.json found - project needs to be compiled"
        fi
        return 0
    else
        error "No aiken.toml found at $project_dir"
        return 1
    fi
}

check_node_modules() {
    local offchain_dir=$1
    
    if [[ -d "$offchain_dir" && -f "$offchain_dir/package.json" ]]; then
        if [[ -d "$offchain_dir/node_modules" ]]; then
            success "Node.js dependencies are installed"
            return 0
        else
            warn "Node.js dependencies not installed - run 'npm install' in $offchain_dir"
            return 1
        fi
    else
        info "No Node.js project found in $offchain_dir"
        return 0
    fi
}

check_python_env() {
    local offchain_dir=$1
    
    if [[ -d "$offchain_dir" && -f "$offchain_dir/requirements.txt" ]]; then
        if [[ -d "$offchain_dir/venv" ]]; then
            success "Python virtual environment found"
            return 0
        else
            warn "Python virtual environment not found - should be created in $offchain_dir/venv"
            return 1
        fi
    else
        info "No Python project found in $offchain_dir"
        return 0
    fi
}

# Main function
main() {
    local network=${1:-"preprod"}
    local example=${2:-"hello-world"}
    
    echo "========================================"
    echo "   AIKEN TESTNET ENVIRONMENT CHECK"
    echo "========================================"
    echo "Network: $network"
    echo "Example: $example"
    echo
    
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local testnet_dir="$(dirname "$script_dir")"
    local repo_root="$(dirname "$testnet_dir")"
    local example_dir="$repo_root/examples/$example"
    local config_file="$testnet_dir/configs/$network.env"
    
    local checks_passed=0
    local total_checks=0
    
    # Core tools check
    info "Checking core tools..."
    ((total_checks++))
    if check_command "aiken"; then ((checks_passed++)); fi
    
    ((total_checks++))
    if check_command "cardano-cli"; then ((checks_passed++)); fi
    
    ((total_checks++))
    if check_command "jq"; then ((checks_passed++)); fi
    
    ((total_checks++))
    if check_command "curl"; then ((checks_passed++)); fi
    
    echo
    
    # Project structure check
    info "Checking project structure..."
    ((total_checks++))
    if check_aiken_project "$example_dir"; then ((checks_passed++)); fi
    
    echo
    
    # Network configuration check
    info "Checking network configuration..."
    ((total_checks++))
    if check_blockfrost_config "$network" "$config_file"; then ((checks_passed++)); fi
    
    ((total_checks++))
    if check_network_connectivity "$network"; then ((checks_passed++)); fi
    
    echo
    
    # Off-chain tools check
    info "Checking off-chain integration tools..."
    
    # Node.js check
    if command -v node >/dev/null 2>&1; then
        success "Node.js is available: $(node --version)"
        ((total_checks++))
        if check_node_modules "$example_dir/offchain"; then ((checks_passed++)); fi
    else
        info "Node.js not found - Mesh integration won't be available"
    fi
    
    # Python check
    if command -v python3 >/dev/null 2>&1; then
        success "Python3 is available: $(python3 --version)"
        ((total_checks++))
        if check_python_env "$example_dir/offchain"; then ((checks_passed++)); fi
    else
        info "Python3 not found - PyCardano integration won't be available"
    fi
    
    echo
    
    # Cardano node check (optional for Blockfrost users)
    info "Checking Cardano node connection (optional)..."
    check_node_socket "${CARDANO_NODE_SOCKET_PATH:-/tmp/cardano-node.socket}"
    
    echo
    echo "========================================"
    echo "           SUMMARY"
    echo "========================================"
    echo "Checks passed: $checks_passed/$total_checks"
    
    if [[ $checks_passed -eq $total_checks ]]; then
        success "All environment checks passed! Ready for deployment."
        return 0
    elif [[ $checks_passed -gt $((total_checks / 2)) ]]; then
        warn "Most checks passed, but some issues need attention."
        return 1
    else
        error "Multiple environment issues detected. Please fix before deployment."
        return 2
    fi
}

# Handle command line arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi



