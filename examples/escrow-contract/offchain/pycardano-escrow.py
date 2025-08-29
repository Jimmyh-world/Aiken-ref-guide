#!/usr/bin/env python3
"""
Escrow Contract Integration with PyCardano

Complete example showing how to interact with the Aiken escrow contract
using PyCardano for transaction building and wallet integration.

Prerequisites:
- pip install pycardano blockfrost-python
- Cardano wallet with testnet ADA
- Blockfrost API key
"""

import os
import time
import json
from dataclasses import dataclass
from typing import Optional, List, Dict, Any
from datetime import datetime, timedelta

from pycardano import *
from blockfrost import BlockFrostApi, ApiError

# Configuration
BLOCKFROST_API_KEY = os.environ.get('BLOCKFROST_API_KEY', 'YOUR_API_KEY')
NETWORK = Network.TESTNET  # or Network.MAINNET
BLOCKFROST_URL = "https://cardano-testnet.blockfrost.io/api/v0"

@dataclass
class EscrowConfig:
    """Configuration for escrow contract"""
    buyer: bytes
    seller: bytes  
    amount: int
    deadline: int
    nonce: int
    state: str = "Active"

class EscrowContract:
    """
    Aiken Escrow Contract Interface
    
    Handles all interactions with the escrow smart contract including
    fund locking, completion, cancellation, and refund operations.
    """
    
    def __init__(self, blockfrost_api_key: str, network: Network = Network.TESTNET):
        """Initialize escrow contract interface"""
        self.network = network
        self.api = BlockFrostApi(api_key=blockfrost_api_key, base_url=BLOCKFROST_URL)
        self.chain_context = self._create_chain_context()
        self.script = self._load_escrow_script()
        
    def _create_chain_context(self) -> ChainContext:
        """Create chain context for transaction building"""
        return ChainContext.builder().blockfrost_api(
            project_id=BLOCKFROST_API_KEY,
            base_url=BLOCKFROST_URL
        ).build()
    
    def _load_escrow_script(self) -> PlutusV2Script:
        """Load compiled Aiken escrow script from plutus.json"""
        try:
            with open('../plutus.json', 'r') as f:
                plutus_data = json.load(f)
            
            # Extract escrow validator
            validators = plutus_data.get('validators', [])
            escrow_validator = None
            
            for validator in validators:
                if 'escrow' in validator.get('title', '').lower():
                    escrow_validator = validator
                    break
            
            if not escrow_validator:
                raise ValueError("Escrow validator not found in plutus.json")
            
            # Create PlutusV2Script from compiled code
            script_hex = escrow_validator['compiledCode']
            script_bytes = bytes.fromhex(script_hex)
            
            return PlutusV2Script(script_bytes)
            
        except FileNotFoundError:
            print("⚠️  Warning: plutus.json not found, using mock script")
            # Return mock script for demonstration
            return PlutusV2Script(b"mock_script_for_demo")
    
    def create_escrow_datum(self, config: EscrowConfig) -> PlutusData:
        """Create escrow datum from configuration"""
        return PlutusData.from_cbor(
            CBOREncoder.encode({
                "constructor": 0,
                "fields": [
                    {"bytes": config.buyer.hex()},
                    {"bytes": config.seller.hex()},
                    {"int": config.amount},
                    {"int": config.deadline},
                    {"int": config.nonce},
                    {
                        "constructor": 0 if config.state == "Active" else 1,
                        "fields": []
                    }
                ]
            })
        )
    
    def create_escrow_redeemer(self, action: str) -> Redeemer:
        """Create redeemer for escrow actions"""
        action_map = {
            "complete": {"constructor": 0, "fields": []},  # CompleteEscrow
            "cancel": {"constructor": 1, "fields": []},    # CancelEscrow  
            "refund": {"constructor": 2, "fields": []}     # RefundEscrow
        }
        
        if action not in action_map:
            raise ValueError(f"Unknown action: {action}")
        
        redeemer_data = PlutusData.from_cbor(
            CBOREncoder.encode(action_map[action])
        )
        
        return Redeemer(redeemer_data)
    
    def get_script_address(self) -> Address:
        """Get the script address for the escrow contract"""
        script_hash = script_hash_from_bytes(self.script.data)
        return Address(script_hash, network=self.network)
    
    def lock_funds(self, 
                   payment_key: PaymentSigningKey,
                   seller_address: str,
                   amount_lovelace: int,
                   deadline_hours: int = 24) -> str:
        """
        Lock funds in escrow contract
        
        Args:
            payment_key: Buyer's payment signing key
            seller_address: Seller's address
            amount_lovelace: Amount to lock in Lovelace
            deadline_hours: Hours until deadline
            
        Returns:
            Transaction hash
        """
        try:
            # Get buyer's address and key hash
            buyer_address = Address.from_primitive(
                payment_key.to_verification_key().hash().payload
            )
            buyer_key_hash = payment_key.to_verification_key().hash().payload
            
            # Parse seller address and get key hash
            seller_addr = Address.from_bech32(seller_address)
            seller_key_hash = seller_addr.payment_part
            
            # Calculate deadline
            deadline = int(time.time()) + (deadline_hours * 3600)
            
            # Generate unique nonce
            nonce = int(time.time() * 1000) % 1000000
            
            # Create escrow configuration
            config = EscrowConfig(
                buyer=buyer_key_hash,
                seller=seller_key_hash,
                amount=amount_lovelace,
                deadline=deadline,
                nonce=nonce
            )
            
            # Create datum
            datum = self.create_escrow_datum(config)
            
            # Get script address
            script_address = self.get_script_address()
            
            # Build transaction
            builder = TransactionBuilder(self.chain_context)
            
            # Add input (will be auto-selected by builder)
            builder.add_input_address(buyer_address)
            
            # Add output to script with datum
            builder.add_output(
                TransactionOutput(
                    address=script_address,
                    amount=Value(coin=amount_lovelace),
                    datum=datum
                )
            )
            
            # Build and sign transaction
            transaction = builder.build_and_sign(
                signing_keys=[payment_key],
                change_address=buyer_address
            )
            
            # Submit transaction
            tx_id = self.chain_context.submit_tx(transaction)
            
            print(f"✅ Escrow created!")
            print(f"   Transaction ID: {tx_id}")
            print(f"   Amount: {amount_lovelace / 1_000_000:.6f} ADA")
            print(f"   Deadline: {datetime.fromtimestamp(deadline)}")
            print(f"   Nonce: {nonce}")
            
            return str(tx_id)
            
        except Exception as error:
            print(f"❌ Failed to lock funds: {error}")
            raise
    
    def complete_escrow(self,
                       payment_key: PaymentSigningKey,
                       escrow_utxo: UTxO,
                       original_datum: PlutusData) -> str:
        """
        Complete escrow transaction
        
        Args:
            payment_key: Buyer's payment signing key
            escrow_utxo: UTxO containing the escrow
            original_datum: Original escrow datum
            
        Returns:
            Transaction hash
        """
        try:
            # Get buyer's address
            buyer_address = Address.from_primitive(
                payment_key.to_verification_key().hash().payload
            )
            
            # Create completion redeemer
            redeemer = self.create_escrow_redeemer("complete")
            
            # Build transaction
            builder = TransactionBuilder(self.chain_context)
            
            # Add script input
            builder.add_script_input(
                utxo=escrow_utxo,
                script=self.script,
                datum=original_datum,
                redeemer=redeemer
            )
            
            # Set validity interval (before deadline)
            current_time = int(time.time())
            builder.validity_start = current_time
            builder.ttl = current_time + 900  # 15 minutes
            
            # Build and sign transaction
            transaction = builder.build_and_sign(
                signing_keys=[payment_key],
                change_address=buyer_address
            )
            
            # Submit transaction
            tx_id = self.chain_context.submit_tx(transaction)
            
            print(f"✅ Escrow completed!")
            print(f"   Transaction ID: {tx_id}")
            
            return str(tx_id)
            
        except Exception as error:
            print(f"❌ Failed to complete escrow: {error}")
            raise
    
    def cancel_escrow(self,
                     payment_key: PaymentSigningKey,
                     escrow_utxo: UTxO,
                     original_datum: PlutusData) -> str:
        """
        Cancel escrow transaction (before deadline)
        
        Args:
            payment_key: Buyer's payment signing key
            escrow_utxo: UTxO containing the escrow
            original_datum: Original escrow datum
            
        Returns:
            Transaction hash
        """
        try:
            # Get buyer's address
            buyer_address = Address.from_primitive(
                payment_key.to_verification_key().hash().payload
            )
            
            # Create cancellation redeemer
            redeemer = self.create_escrow_redeemer("cancel")
            
            # Build transaction
            builder = TransactionBuilder(self.chain_context)
            
            # Add script input
            builder.add_script_input(
                utxo=escrow_utxo,
                script=self.script,
                datum=original_datum,
                redeemer=redeemer
            )
            
            # Set validity interval
            current_time = int(time.time())
            builder.validity_start = current_time
            builder.ttl = current_time + 900
            
            # Build and sign transaction
            transaction = builder.build_and_sign(
                signing_keys=[payment_key],
                change_address=buyer_address
            )
            
            # Submit transaction
            tx_id = self.chain_context.submit_tx(transaction)
            
            print(f"✅ Escrow cancelled!")
            print(f"   Transaction ID: {tx_id}")
            
            return str(tx_id)
            
        except Exception as error:
            print(f"❌ Failed to cancel escrow: {error}")
            raise
    
    def find_escrow_utxos(self) -> List[UTxO]:
        """Find all UTxOs at the escrow script address"""
        try:
            script_address = self.get_script_address()
            utxos = self.chain_context.utxos(str(script_address))
            
            # Filter for UTxOs with datums (escrow contracts)
            escrow_utxos = [utxo for utxo in utxos if utxo.output.datum]
            
            print(f"🔍 Found {len(escrow_utxos)} escrow UTxOs")
            return escrow_utxos
            
        except Exception as error:
            print(f"❌ Failed to find escrow UTxOs: {error}")
            return []

def create_test_keys() -> tuple[PaymentSigningKey, PaymentSigningKey]:
    """Create test keys for buyer and seller"""
    buyer_key = PaymentSigningKey.generate()
    seller_key = PaymentSigningKey.generate()
    
    return buyer_key, seller_key

def example_usage():
    """Example demonstrating complete escrow workflow"""
    print("🚀 PyCardano Escrow Example\n")
    
    try:
        # Initialize escrow contract
        escrow = EscrowContract(BLOCKFROST_API_KEY, NETWORK)
        
        # Create test keys (in production, load from secure storage)
        buyer_key, seller_key = create_test_keys()
        
        # Get addresses
        buyer_address = Address.from_primitive(
            buyer_key.to_verification_key().hash().payload
        )
        seller_address = Address.from_primitive(
            seller_key.to_verification_key().hash().payload
        )
        
        print(f"👤 Buyer address: {buyer_address}")
        print(f"👤 Seller address: {seller_address}")
        
        # Step 1: Lock funds
        print("\n📝 Step 1: Locking 5 ADA in escrow...")
        amount = 5_000_000  # 5 ADA in Lovelace
        
        lock_tx = escrow.lock_funds(
            payment_key=buyer_key,
            seller_address=str(seller_address),
            amount_lovelace=amount,
            deadline_hours=24
        )
        
        print(f"   Lock transaction: {lock_tx}")
        
        # Wait for confirmation
        print("\n⏳ Waiting for transaction confirmation...")
        time.sleep(30)
        
        # Step 2: Find escrow
        print("\n🔍 Step 2: Finding escrow UTxO...")
        escrow_utxos = escrow.find_escrow_utxos()
        
        if escrow_utxos:
            print(f"   Found escrow at: {escrow_utxos[0].input}")
            
            # Step 3: Complete escrow (optional)
            print("\n✅ Step 3: Completing escrow...")
            # Note: In real usage, you'd need the original datum
            # This is a simplified example
            
        print("\n🎉 Example completed!")
        
    except Exception as error:
        print(f"\n💥 Example failed: {error}")

if __name__ == "__main__":
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python pycardano-escrow.py [example|lock|complete|cancel]")
        sys.exit(1)
    
    command = sys.argv[1]
    
    if command == "example":
        example_usage()
    elif command == "lock":
        print("Implement lock command...")
    elif command == "complete":
        print("Implement complete command...")
    elif command == "cancel":
        print("Implement cancel command...")
    else:
        print("Unknown command. Use: example, lock, complete, or cancel")
