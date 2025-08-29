#!/bin/bash
# Escrow Contract Integration with cardano-cli
#
# Complete example showing how to interact with the Aiken escrow contract
# using raw cardano-cli commands for maximum control and transparency.
#
# Prerequisites:
# - cardano-cli installed and in PATH
# - cardano-node running and synced
# - Payment keys and addresses set up
# - Testnet ADA for transactions

set -e  # Exit on any error

# Configuration
NETWORK="--testnet-magic 1"  # Use --mainnet for mainnet
SCRIPT_FILE="../plutus.json"
PROTOCOL_PARAMS="protocol-params.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Utility functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check cardano-cli
    if ! command -v cardano-cli &> /dev/null; then
        log_error "cardano-cli not found. Please install cardano-node."
        exit 1
    fi
    
    # Check script file
    if [ ! -f "$SCRIPT_FILE" ]; then
        log_error "Script file not found: $SCRIPT_FILE"
        log_info "Run 'aiken build' in the contract directory first."
        exit 1
    fi
    
    # Get protocol parameters
    if [ ! -f "$PROTOCOL_PARAMS" ]; then
        log_info "Downloading protocol parameters..."
        cardano-cli query protocol-parameters $NETWORK --out-file $PROTOCOL_PARAMS
    fi
    
    log_success "Prerequisites checked"
}

# Extract script information
extract_script_info() {
    log_info "Extracting script information..."
    
    # Extract escrow validator from plutus.json
    ESCROW_SCRIPT=$(jq -r '.validators[] | select(.title | test("escrow"; "i")) | .compiledCode' "$SCRIPT_FILE")
    
    if [ "$ESCROW_SCRIPT" = "null" ] || [ -z "$ESCROW_SCRIPT" ]; then
        log_error "Escrow validator not found in $SCRIPT_FILE"
        exit 1
    fi
    
    # Create script file
    cat > escrow-script.plutus << EOF
{
    "type": "PlutusScriptV2",
    "description": "Aiken Escrow Contract",
    "cborHex": "$ESCROW_SCRIPT"
}
EOF
    
    # Calculate script address
    SCRIPT_ADDRESS=$(cardano-cli address build \
        --payment-script-file escrow-script.plutus \
        $NETWORK)
    
    log_success "Script address: $SCRIPT_ADDRESS"
}

# Create escrow datum
create_escrow_datum() {
    local buyer_pkh="$1"
    local seller_pkh="$2"
    local amount="$3"
    local deadline="$4"
    local nonce="$5"
    
    # Create datum JSON (Aiken escrow format)
    cat > escrow-datum.json << EOF
{
    "constructor": 0,
    "fields": [
        {
            "bytes": "$buyer_pkh"
        },
        {
            "bytes": "$seller_pkh"
        },
        {
            "int": $amount
        },
        {
            "int": $deadline
        },
        {
            "int": $nonce
        },
        {
            "constructor": 0,
            "fields": []
        }
    ]
}
EOF
    
    # Convert to CBOR
    cardano-cli transaction hash-script-data \
        --script-data-file escrow-datum.json \
        --out-file escrow-datum-hash.txt
    
    log_success "Created escrow datum"
}

# Create escrow redeemer
create_escrow_redeemer() {
    local action="$1"
    
    case "$action" in
        "complete")
            constructor=0
            ;;
        "cancel")
            constructor=1
            ;;
        "refund")
            constructor=2
            ;;
        *)
            log_error "Unknown action: $action"
            exit 1
            ;;
    esac
    
    # Create redeemer JSON
    cat > escrow-redeemer.json << EOF
{
    "constructor": $constructor,
    "fields": []
}
EOF
    
    log_success "Created $action redeemer"
}

# Lock funds in escrow
lock_funds() {
    local buyer_addr="$1"
    local buyer_skey="$2"
    local seller_pkh="$3"
    local amount="$4"
    local deadline_hours="${5:-24}"
    
    log_info "Locking $amount Lovelace in escrow..."
    
    # Get buyer's public key hash
    local buyer_pkh=$(cardano-cli address key-hash \
        --payment-verification-key-file "${buyer_skey%.skey}.vkey")
    
    # Calculate deadline (hours from now)
    local deadline=$(($(date +%s) + deadline_hours * 3600))
    
    # Generate unique nonce
    local nonce=$(($(date +%s%N) % 1000000))
    
    # Create datum
    create_escrow_datum "$buyer_pkh" "$seller_pkh" "$amount" "$deadline" "$nonce"
    
    # Query UTxOs at buyer address
    cardano-cli query utxo --address "$buyer_addr" $NETWORK --out-file buyer-utxos.json
    
    # Select input UTxO (simplified - use first available)
    local tx_in=$(jq -r 'to_entries[0].key' buyer-utxos.json)
    local tx_in_amount=$(jq -r 'to_entries[0].value.value.lovelace' buyer-utxos.json)
    
    if [ "$tx_in_amount" -lt $((amount + 2000000)) ]; then
        log_error "Insufficient funds. Need at least $((amount + 2000000)) Lovelace"
        exit 1
    fi
    
    # Build transaction
    cardano-cli transaction build \
        --tx-in "$tx_in" \
        --tx-out "$SCRIPT_ADDRESS+$amount" \
        --tx-out-datum-embed-file escrow-datum.json \
        --change-address "$buyer_addr" \
        --protocol-params-file $PROTOCOL_PARAMS \
        $NETWORK \
        --out-file lock-tx.raw
    
    # Sign transaction
    cardano-cli transaction sign \
        --tx-body-file lock-tx.raw \
        --signing-key-file "$buyer_skey" \
        $NETWORK \
        --out-file lock-tx.signed
    
    # Submit transaction
    local tx_id=$(cardano-cli transaction submit --tx-file lock-tx.signed $NETWORK)
    
    log_success "Escrow created!"
    log_info "Transaction ID: $tx_id"
    log_info "Amount: $(echo "scale=6; $amount / 1000000" | bc) ADA"
    log_info "Deadline: $(date -d "@$deadline")"
    log_info "Nonce: $nonce"
    
    # Save escrow info for later use
    cat > escrow-info.json << EOF
{
    "tx_id": "$tx_id",
    "amount": $amount,
    "deadline": $deadline,
    "nonce": $nonce,
    "buyer_pkh": "$buyer_pkh",
    "seller_pkh": "$seller_pkh"
}
EOF
}

# Complete escrow transaction
complete_escrow() {
    local buyer_addr="$1"
    local buyer_skey="$2"
    local escrow_utxo="$3"
    
    log_info "Completing escrow transaction..."
    
    # Create completion redeemer
    create_escrow_redeemer "complete"
    
    # Query UTxOs at script address
    cardano-cli query utxo --address "$SCRIPT_ADDRESS" $NETWORK --out-file script-utxos.json
    
    # Get escrow UTxO amount
    local escrow_amount=$(jq -r ".[\"$escrow_utxo\"].value.lovelace" script-utxos.json)
    
    if [ "$escrow_amount" = "null" ]; then
        log_error "Escrow UTxO not found: $escrow_utxo"
        exit 1
    fi
    
    # Calculate current time for validity range
    local current_time=$(date +%s)
    local valid_from=$current_time
    local valid_to=$((current_time + 900))  # 15 minutes
    
    # Build transaction
    cardano-cli transaction build \
        --tx-in "$escrow_utxo" \
        --tx-in-script-file escrow-script.plutus \
        --tx-in-datum-file escrow-datum.json \
        --tx-in-redeemer-file escrow-redeemer.json \
        --tx-in-execution-units "(1000000, 10000)" \
        --change-address "$buyer_addr" \
        --invalid-before "$valid_from" \
        --invalid-hereafter "$valid_to" \
        --protocol-params-file $PROTOCOL_PARAMS \
        $NETWORK \
        --out-file complete-tx.raw
    
    # Sign transaction
    cardano-cli transaction sign \
        --tx-body-file complete-tx.raw \
        --signing-key-file "$buyer_skey" \
        $NETWORK \
        --out-file complete-tx.signed
    
    # Submit transaction
    local tx_id=$(cardano-cli transaction submit --tx-file complete-tx.signed $NETWORK)
    
    log_success "Escrow completed!"
    log_info "Transaction ID: $tx_id"
}

# Cancel escrow transaction
cancel_escrow() {
    local buyer_addr="$1"
    local buyer_skey="$2"
    local escrow_utxo="$3"
    
    log_info "Cancelling escrow transaction..."
    
    # Create cancellation redeemer
    create_escrow_redeemer "cancel"
    
    # Calculate current time for validity range
    local current_time=$(date +%s)
    local valid_from=$current_time
    local valid_to=$((current_time + 900))
    
    # Build transaction
    cardano-cli transaction build \
        --tx-in "$escrow_utxo" \
        --tx-in-script-file escrow-script.plutus \
        --tx-in-datum-file escrow-datum.json \
        --tx-in-redeemer-file escrow-redeemer.json \
        --tx-in-execution-units "(1000000, 10000)" \
        --change-address "$buyer_addr" \
        --invalid-before "$valid_from" \
        --invalid-hereafter "$valid_to" \
        --protocol-params-file $PROTOCOL_PARAMS \
        $NETWORK \
        --out-file cancel-tx.raw
    
    # Sign transaction
    cardano-cli transaction sign \
        --tx-body-file cancel-tx.raw \
        --signing-key-file "$buyer_skey" \
        $NETWORK \
        --out-file cancel-tx.signed
    
    # Submit transaction
    local tx_id=$(cardano-cli transaction submit --tx-file cancel-tx.signed $NETWORK)
    
    log_success "Escrow cancelled!"
    log_info "Transaction ID: $tx_id"
}

# Query escrow UTxOs
query_escrows() {
    log_info "Querying escrow UTxOs..."
    
    cardano-cli query utxo --address "$SCRIPT_ADDRESS" $NETWORK
    
    log_success "Escrow query completed"
}

# Display help
show_help() {
    echo "Aiken Escrow Contract - cardano-cli Interface"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  lock <buyer-addr> <buyer-skey> <seller-pkh> <amount> [deadline-hours]"
    echo "    Lock funds in escrow"
    echo ""
    echo "  complete <buyer-addr> <buyer-skey> <escrow-utxo>"
    echo "    Complete escrow transaction"
    echo ""
    echo "  cancel <buyer-addr> <buyer-skey> <escrow-utxo>"
    echo "    Cancel escrow transaction"
    echo ""
    echo "  query"
    echo "    Query all escrow UTxOs"
    echo ""
    echo "  help"
    echo "    Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 lock addr_test1... buyer.skey abc123... 5000000 24"
    echo "  $0 complete addr_test1... buyer.skey tx123...#0"
    echo "  $0 cancel addr_test1... buyer.skey tx123...#0"
    echo "  $0 query"
}

# Main script logic
main() {
    case "${1:-help}" in
        "lock")
            check_prerequisites
            extract_script_info
            lock_funds "$2" "$3" "$4" "$5" "$6"
            ;;
        "complete")
            check_prerequisites
            extract_script_info
            complete_escrow "$2" "$3" "$4"
            ;;
        "cancel")
            check_prerequisites
            extract_script_info
            cancel_escrow "$2" "$3" "$4"
            ;;
        "query")
            check_prerequisites
            extract_script_info
            query_escrows
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Run main function with all arguments
main "$@"
