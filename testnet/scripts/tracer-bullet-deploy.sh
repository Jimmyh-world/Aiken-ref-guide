#!/bin/bash

# Aiken Testnet Tracer Bullet Deployment Script
# Tests multiple deployment configurations and tools to validate setup

set -euo pipefail

# Script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTNET_DIR="$(dirname "$SCRIPT_DIR")"
REPO_ROOT="$(dirname "$TESTNET_DIR")"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "[${timestamp}] ${level}: ${message}"
    if [[ -n "${LOG_FILE:-}" ]]; then
        echo "[${timestamp}] ${level}: ${message}" >> "$LOG_FILE"
    fi
}

info() { log "${BLUE}INFO${NC}" "$@"; }
warn() { log "${YELLOW}WARN${NC}" "$@"; }
error() { log "${RED}ERROR${NC}" "$@"; }
success() { log "${GREEN}SUCCESS${NC}" "$@"; }

# Usage function
usage() {
    cat << EOF
Usage: $0 [OPTIONS] NETWORK EXAMPLE DEPLOYMENT_METHOD

Tracer bullet deployment testing for Aiken contracts

ARGUMENTS:
    NETWORK           Target network (preprod|preview|local)
    EXAMPLE          Example to deploy (hello-world|escrow-contract|voting-contracts)
    DEPLOYMENT_METHOD Deployment method (cardano-cli|mesh|pycardano|all)

OPTIONS:
    -h, --help       Show this help message
    -v, --verbose    Enable verbose output
    -d, --dry-run    Show what would be done without executing
    -c, --cleanup    Clean up previous deployment artifacts
    --skip-build     Skip the Aiken build step
    --continue-on-error  Continue testing other methods if one fails

EXAMPLES:
    $0 preprod hello-world cardano-cli
    $0 preview escrow-contract all
    $0 --dry-run preprod voting-contracts mesh

EOF
}

# Default values
VERBOSE=false
DRY_RUN=false
CLEANUP=false
SKIP_BUILD=false
CONTINUE_ON_ERROR=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -c|--cleanup)
            CLEANUP=true
            shift
            ;;
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        --continue-on-error)
            CONTINUE_ON_ERROR=true
            shift
            ;;
        -*)
            error "Unknown option: $1"
            usage
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

# Validate required arguments
if [[ $# -lt 3 ]]; then
    error "Missing required arguments"
    usage
    exit 1
fi

NETWORK=$1
EXAMPLE=$2
DEPLOYMENT_METHOD=$3

# Validate network
case $NETWORK in
    preprod|preview|local)
        ;;
    *)
        error "Invalid network: $NETWORK. Must be preprod, preview, or local"
        exit 1
        ;;
esac

# Validate example
case $EXAMPLE in
    hello-world|escrow-contract|voting-contracts)
        ;;
    *)
        error "Invalid example: $EXAMPLE. Must be hello-world, escrow-contract, or voting-contracts"
        exit 1
        ;;
esac

# Validate deployment method
case $DEPLOYMENT_METHOD in
    cardano-cli|mesh|pycardano|all)
        ;;
    *)
        error "Invalid deployment method: $DEPLOYMENT_METHOD"
        exit 1
        ;;
esac

# Load network configuration
CONFIG_FILE="$TESTNET_DIR/configs/$NETWORK.env"
if [[ ! -f "$CONFIG_FILE" ]]; then
    error "Configuration file not found: $CONFIG_FILE"
    exit 1
fi

info "Loading configuration from $CONFIG_FILE"
source "$CONFIG_FILE"

# Set example directory
EXAMPLE_DIR="$REPO_ROOT/examples/$EXAMPLE"
if [[ ! -d "$EXAMPLE_DIR" ]]; then
    error "Example directory not found: $EXAMPLE_DIR"
    exit 1
fi

# Initialize log file
mkdir -p "$(dirname "$LOG_FILE")"
if [[ $DRY_RUN == false ]]; then
    echo "=== Tracer Bullet Deployment Log - $(date) ===" > "$LOG_FILE"
fi

# Results tracking
RESULTS_FILE="$TESTNET_DIR/results/${NETWORK}-${EXAMPLE}-$(date +%Y%m%d-%H%M%S).json"
mkdir -p "$(dirname "$RESULTS_FILE")"

# Initialize results
cat > "$RESULTS_FILE" << EOF
{
    "deployment_id": "${NETWORK}-${EXAMPLE}-$(date +%Y%m%d-%H%M%S)",
    "network": "$NETWORK",
    "example": "$EXAMPLE",
    "deployment_method": "$DEPLOYMENT_METHOD",
    "start_time": "$(date -Iseconds)",
    "configuration": {
        "network_name": "$NETWORK_NAME",
        "testnet_magic": "$TESTNET_MAGIC",
        "skip_build": $SKIP_BUILD,
        "continue_on_error": $CONTINUE_ON_ERROR
    },
    "results": {},
    "errors": [],
    "recommendations": []
}
EOF

# Function to update results
update_results() {
    local method=$1
    local status=$2
    local details=$3
    local execution_time=${4:-0}
    
    # Create temporary file for jq processing
    local temp_file=$(mktemp)
    
    jq --arg method "$method" \
       --arg status "$status" \
       --arg details "$details" \
       --arg exec_time "$execution_time" \
       '.results[$method] = {
           "status": $status,
           "details": $details,
           "execution_time": $exec_time,
           "timestamp": now | strftime("%Y-%m-%dT%H:%M:%S%z")
       }' "$RESULTS_FILE" > "$temp_file"
    
    mv "$temp_file" "$RESULTS_FILE"
}

# Function to add error
add_error() {
    local method=$1
    local error_msg=$2
    
    local temp_file=$(mktemp)
    
    jq --arg method "$method" \
       --arg error "$error_msg" \
       '.errors += [{
           "method": $method,
           "error": $error,
           "timestamp": now | strftime("%Y-%m-%dT%H:%M:%S%z")
       }]' "$RESULTS_FILE" > "$temp_file"
    
    mv "$temp_file" "$RESULTS_FILE"
}

# Cleanup function
cleanup_artifacts() {
    if [[ $CLEANUP == true ]]; then
        info "Cleaning up previous deployment artifacts..."
        if [[ $DRY_RUN == false ]]; then
            cd "$EXAMPLE_DIR"
            rm -f *.addr *.plutus *.raw *.signed tx-*.* datum.json redeemer.json
            rm -rf deployment_temp/
        fi
        success "Cleanup completed"
    fi
}

# Build function
build_contract() {
    if [[ $SKIP_BUILD == true ]]; then
        info "Skipping build step as requested"
        return 0
    fi
    
    info "Building Aiken contract..."
    if [[ $DRY_RUN == true ]]; then
        info "DRY RUN: Would execute 'aiken build' in $EXAMPLE_DIR"
        return 0
    fi
    
    cd "$EXAMPLE_DIR"
    local start_time=$(date +%s)
    
    if aiken build 2>&1 | tee -a "$LOG_FILE"; then
        local end_time=$(date +%s)
        local build_time=$((end_time - start_time))
        success "Build completed successfully in ${build_time}s"
        update_results "build" "success" "Contract built successfully" "$build_time"
    else
        error "Build failed"
        add_error "build" "Aiken build command failed"
        return 1
    fi
}

# Cardano CLI deployment
deploy_cardano_cli() {
    info "Testing deployment with cardano-cli..."
    local start_time=$(date +%s)
    
    if [[ $DRY_RUN == true ]]; then
        info "DRY RUN: Would deploy using cardano-cli method"
        update_results "cardano-cli" "dry-run" "Dry run completed"
        return 0
    fi
    
    cd "$EXAMPLE_DIR"
    
    # Check if we have the necessary CLI scripts
    local cli_script=""
    case $EXAMPLE in
        hello-world)
            cli_script="scripts/lock.sh"
            ;;
        escrow-contract)
            cli_script="offchain/cardano-cli-escrow.sh"
            ;;
        voting-contracts)
            cli_script="scripts/deploy.sh"  # We'll need to create this
            ;;
    esac
    
    if [[ -f "$cli_script" ]]; then
        info "Using existing CLI script: $cli_script"
        if bash "$cli_script" 2>&1 | tee -a "$LOG_FILE"; then
            local end_time=$(date +%s)
            local deploy_time=$((end_time - start_time))
            success "cardano-cli deployment completed in ${deploy_time}s"
            update_results "cardano-cli" "success" "Deployment completed successfully" "$deploy_time"
        else
            error "cardano-cli deployment failed"
            add_error "cardano-cli" "CLI script execution failed"
            return 1
        fi
    else
        warn "No CLI script found for $EXAMPLE, creating basic deployment..."
        # Basic deployment using the pattern from docs
        if deploy_basic_cli; then
            local end_time=$(date +%s)
            local deploy_time=$((end_time - start_time))
            success "Basic cardano-cli deployment completed in ${deploy_time}s"
            update_results "cardano-cli" "success" "Basic deployment completed" "$deploy_time"
        else
            error "Basic cardano-cli deployment failed"
            add_error "cardano-cli" "Basic CLI deployment failed"
            return 1
        fi
    fi
}

# Basic CLI deployment function
deploy_basic_cli() {
    info "Performing basic cardano-cli deployment..."
    
    # Extract CBOR from plutus.json
    if [[ ! -f "plutus.json" ]]; then
        error "plutus.json not found"
        return 1
    fi
    
    # Get the first validator (adjust this logic based on your needs)
    local validator_cbor=$(jq -r '.validators[0].compiledCode' plutus.json)
    if [[ "$validator_cbor" == "null" || -z "$validator_cbor" ]]; then
        error "Could not extract validator CBOR from plutus.json"
        return 1
    fi
    
    # Create script file
    cat > validator.plutus << EOF
{
    "type": "PlutusScriptV2",
    "description": "Aiken Validator - $EXAMPLE",
    "cborHex": "$validator_cbor"
}
EOF
    
    # Generate script address
    cardano-cli address build \
        --payment-script-file validator.plutus \
        --testnet-magic "$TESTNET_MAGIC" \
        --out-file validator.addr
    
    local script_address=$(cat validator.addr)
    info "Generated script address: $script_address"
    
    # Validate the address was created
    if [[ -z "$script_address" ]]; then
        error "Failed to generate script address"
        return 1
    fi
    
    success "Basic CLI deployment validation completed"
    return 0
}

# Mesh deployment
deploy_mesh() {
    info "Testing deployment with Mesh..."
    local start_time=$(date +%s)
    
    if [[ $DRY_RUN == true ]]; then
        info "DRY RUN: Would deploy using Mesh method"
        update_results "mesh" "dry-run" "Dry run completed"
        return 0
    fi
    
    cd "$EXAMPLE_DIR"
    
    # Check for Mesh integration
    if [[ -f "offchain/mesh.ts" || -f "offchain/mesh.js" ]]; then
        info "Found Mesh integration files"
        if [[ -f "offchain/package.json" ]]; then
            cd offchain
            if [[ ! -d "node_modules" ]]; then
                info "Installing Mesh dependencies..."
                npm install 2>&1 | tee -a "$LOG_FILE"
            fi
            
            # Set environment variables for Mesh
            export BLOCKFROST_PROJECT_ID="${BLOCKFROST_PROJECT_ID}"
            export BLOCKFROST_URL="${BLOCKFROST_URL}"
            export NETWORK="${NETWORK_NAME}"
            
            # Run Mesh deployment test
            if npm run deploy 2>&1 | tee -a "$LOG_FILE"; then
                local end_time=$(date +%s)
                local deploy_time=$((end_time - start_time))
                success "Mesh deployment completed in ${deploy_time}s"
                update_results "mesh" "success" "Deployment completed successfully" "$deploy_time"
            else
                error "Mesh deployment failed"
                add_error "mesh" "NPM deploy script failed"
                return 1
            fi
            cd ..
        else
            warn "No package.json found for Mesh integration"
            update_results "mesh" "skipped" "No package.json found"
        fi
    else
        warn "No Mesh integration found for $EXAMPLE"
        update_results "mesh" "skipped" "No Mesh files found"
    fi
}

# PyCardano deployment
deploy_pycardano() {
    info "Testing deployment with PyCardano..."
    local start_time=$(date +%s)
    
    if [[ $DRY_RUN == true ]]; then
        info "DRY RUN: Would deploy using PyCardano method"
        update_results "pycardano" "dry-run" "Dry run completed"
        return 0
    fi
    
    cd "$EXAMPLE_DIR"
    
    # Check for PyCardano integration
    if [[ -f "offchain/pycardano.py" || -f "offchain/pycardano-*.py" ]]; then
        info "Found PyCardano integration files"
        if [[ -f "offchain/requirements.txt" ]]; then
            cd offchain
            
            # Check if virtual environment exists or create one
            if [[ ! -d "venv" ]]; then
                info "Creating Python virtual environment..."
                python3 -m venv venv
            fi
            
            source venv/bin/activate
            
            info "Installing PyCardano dependencies..."
            pip install -r requirements.txt 2>&1 | tee -a "$LOG_FILE"
            
            # Set environment variables for PyCardano
            export BLOCKFROST_PROJECT_ID="${BLOCKFROST_PROJECT_ID}"
            export BLOCKFROST_URL="${BLOCKFROST_URL}"
            export NETWORK="${NETWORK_NAME}"
            
            # Find and run PyCardano script
            local pycardano_script=$(ls pycardano*.py | head -1)
            if [[ -n "$pycardano_script" ]]; then
                if python "$pycardano_script" deploy 2>&1 | tee -a "$LOG_FILE"; then
                    local end_time=$(date +%s)
                    local deploy_time=$((end_time - start_time))
                    success "PyCardano deployment completed in ${deploy_time}s"
                    update_results "pycardano" "success" "Deployment completed successfully" "$deploy_time"
                else
                    error "PyCardano deployment failed"
                    add_error "pycardano" "Python script execution failed"
                    deactivate
                    return 1
                fi
            else
                error "No PyCardano script found"
                add_error "pycardano" "No PyCardano script found"
                deactivate
                return 1
            fi
            
            deactivate
            cd ..
        else
            warn "No requirements.txt found for PyCardano integration"
            update_results "pycardano" "skipped" "No requirements.txt found"
        fi
    else
        warn "No PyCardano integration found for $EXAMPLE"
        update_results "pycardano" "skipped" "No PyCardano files found"
    fi
}

# Main deployment function
run_deployment() {
    local method=$1
    local success=true
    
    case $method in
        cardano-cli)
            if ! deploy_cardano_cli; then
                success=false
            fi
            ;;
        mesh)
            if ! deploy_mesh; then
                success=false
            fi
            ;;
        pycardano)
            if ! deploy_pycardano; then
                success=false
            fi
            ;;
        all)
            info "Testing all deployment methods..."
            
            if ! deploy_cardano_cli && [[ $CONTINUE_ON_ERROR == false ]]; then
                success=false
            fi
            
            if ! deploy_mesh && [[ $CONTINUE_ON_ERROR == false ]]; then
                success=false
            fi
            
            if ! deploy_pycardano && [[ $CONTINUE_ON_ERROR == false ]]; then
                success=false
            fi
            ;;
    esac
    
    return $([ "$success" = true ] && echo 0 || echo 1)
}

# Generate summary report
generate_summary() {
    info "Generating deployment summary..."
    
    # Update final results
    local temp_file=$(mktemp)
    jq '.end_time = now | strftime("%Y-%m-%dT%H:%M:%S%z")' "$RESULTS_FILE" > "$temp_file"
    mv "$temp_file" "$RESULTS_FILE"
    
    # Print summary
    echo
    echo "========================================"
    echo "    TRACER BULLET DEPLOYMENT SUMMARY    "
    echo "========================================"
    echo "Network: $NETWORK"
    echo "Example: $EXAMPLE"
    echo "Method: $DEPLOYMENT_METHOD"
    echo "Results file: $RESULTS_FILE"
    echo "Log file: $LOG_FILE"
    echo
    
    # Show results for each method tested
    jq -r '.results | to_entries[] | "  \(.key): \(.value.status) (\(.value.execution_time)s)"' "$RESULTS_FILE"
    
    # Show errors if any
    local error_count=$(jq '.errors | length' "$RESULTS_FILE")
    if [[ $error_count -gt 0 ]]; then
        echo
        echo "Errors encountered:"
        jq -r '.errors[] | "  \(.method): \(.error)"' "$RESULTS_FILE"
    fi
    
    echo "========================================"
}

# Main execution
main() {
    info "Starting tracer bullet deployment..."
    info "Network: $NETWORK"
    info "Example: $EXAMPLE"
    info "Method: $DEPLOYMENT_METHOD"
    info "Configuration: $CONFIG_FILE"
    
    # Cleanup if requested
    cleanup_artifacts
    
    # Build contract
    if ! build_contract; then
        error "Build failed, aborting deployment"
        generate_summary
        exit 1
    fi
    
    # Run deployment
    if run_deployment "$DEPLOYMENT_METHOD"; then
        success "Tracer bullet deployment completed successfully!"
    else
        error "Deployment encountered errors"
        if [[ $CONTINUE_ON_ERROR == false ]]; then
            generate_summary
            exit 1
        fi
    fi
    
    generate_summary
}

# Error handling
trap 'error "Script interrupted"; generate_summary; exit 130' INT TERM

# Check dependencies
check_dependencies() {
    local missing_deps=()
    
    command -v aiken >/dev/null 2>&1 || missing_deps+=("aiken")
    command -v cardano-cli >/dev/null 2>&1 || missing_deps+=("cardano-cli")
    command -v jq >/dev/null 2>&1 || missing_deps+=("jq")
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "Missing required dependencies: ${missing_deps[*]}"
        exit 1
    fi
}

# Run dependency check
check_dependencies

# Execute main function
main "$@"



