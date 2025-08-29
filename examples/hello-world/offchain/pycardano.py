#!/usr/bin/env python3
"""
PyCardano integration for Hello World validator
Complete Python implementation for interacting with the Hello World validator
"""

import os
import json
import argparse
from typing import Optional, Dict, Any
from pycardano import *
from dotenv import load_dotenv

load_dotenv()

class HelloWorldPyCardano:
    def __init__(self, context: ChainContext):
        self.context = context
        self.script_address = Address.from_primitive(
            os.getenv("HELLO_WORLD_SCRIPT_ADDRESS")
        )
    
    def lock(self, amount: int, owner_pkh: bytes) -> str:
        """Lock ADA to Hello World validator"""
        try:
            # Create datum with owner public key hash
            datum = {
                "constructor": 0,
                "fields": [
                    {"bytes": owner_pkh.hex()}
                ]
            }
            
            # Create transaction to lock ADA
            tx_builder = TransactionBuilder(self.context)
            
            # Add input from wallet
            tx_builder.add_input_address(self.context.utxos[0].input.address)
            
            # Add output to script with datum
            tx_builder.add_output(
                TransactionOutput(
                    address=self.script_address,
                    amount=Value.from_primitive([amount, {}]),
                    datum_hash=datum_hash(datum)
                )
            )
            
            # Build and submit transaction
            tx = tx_builder.build_and_sign([self.context.utxos[0].input.address])
            tx_hash = self.context.submit_tx(tx)
            
            return tx_hash
        except Exception as e:
            print(f"Error locking ADA: {e}")
            raise
    
    def unlock(self, script_utxo) -> str:
        """Unlock ADA from Hello World validator"""
        try:
            # Create redeemer with "Hello, World!" message
            redeemer = {
                "constructor": 0,
                "fields": [
                    {"bytes": "Hello, World!"}
                ]
            }
            
            # Create transaction to unlock ADA
            tx_builder = TransactionBuilder(self.context)
            
            # Add script input
            tx_builder.add_script_input(
                script_utxo,
                redeemer=redeemer
            )
            
            # Add output to wallet
            tx_builder.add_output_address(
                self.context.utxos[0].input.address,
                script_utxo.output.amount
            )
            
            # Build and submit transaction
            tx = tx_builder.build_and_sign([self.context.utxos[0].input.address])
            tx_hash = self.context.submit_tx(tx)
            
            return tx_hash
        except Exception as e:
            print(f"Error unlocking ADA: {e}")
            raise
    
    def get_script_utxos(self) -> list:
        """Get all UTxOs at the script address"""
        try:
            utxos = self.context.utxos(self.script_address)
            return utxos
        except Exception as e:
            print(f"Error getting script UTxOs: {e}")
            raise

def datum_hash(datum: Dict[str, Any]) -> bytes:
    """Create datum hash from datum"""
    # Implementation would depend on specific datum format
    # This is a simplified version
    return hashlib.sha256(json.dumps(datum).encode()).digest()

def main():
    parser = argparse.ArgumentParser(description="Hello World Validator CLI")
    parser.add_argument("command", choices=["lock", "unlock", "utxos"], 
                       help="Command to execute")
    parser.add_argument("--amount", type=int, default=10000000,
                       help="Amount in lovelace (default: 10000000)")
    parser.add_argument("--owner-pkh", type=str,
                       help="Owner public key hash")
    
    args = parser.parse_args()
    
    if not os.getenv("HELLO_WORLD_SCRIPT_ADDRESS"):
        print("HELLO_WORLD_SCRIPT_ADDRESS environment variable required")
        exit(1)
    
    try:
        # Initialize context (this would be configured based on network)
        context = ChainContext()
        hello_world = HelloWorldPyCardano(context)
        
        if args.command == "lock":
            owner_pkh = args.owner_pkh or os.getenv("OWNER_PUBKEY_HASH")
            if not owner_pkh:
                print("Owner public key hash required")
                exit(1)
            
            tx_hash = hello_world.lock(args.amount, bytes.fromhex(owner_pkh))
            print(f"Lock transaction: {tx_hash}")
            
        elif args.command == "unlock":
            utxos = hello_world.get_script_utxos()
            if not utxos:
                print("No UTxOs found at script address")
                exit(1)
            
            tx_hash = hello_world.unlock(utxos[0])
            print(f"Unlock transaction: {tx_hash}")
            
        elif args.command == "utxos":
            utxos = hello_world.get_script_utxos()
            print(f"Script UTxOs: {utxos}")
    
    except Exception as e:
        print(f"Error: {e}")
        exit(1)

if __name__ == "__main__":
    main()
