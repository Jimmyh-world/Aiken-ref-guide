#!/usr/bin/env python3
"""
PyCardano connectivity test
Tests basic API connectivity and PyCardano functionality
"""

import os
import sys
import json
import requests
from blockfrost import ApiError, ApiUrls
from blockfrost.api import BlockFrostApi


def test_blockfrost_connectivity():
    """Test Blockfrost API connectivity using blockfrost-python"""
    print("=== TESTING BLOCKFROST CONNECTIVITY (Python) ===")
    
    api_key = "preprodb51DvdEdGkJgVmx1CNnR2EEfWrDtifLR"
    
    try:
        # Initialize Blockfrost API
        print("1. Initializing Blockfrost API...")
        api = BlockFrostApi(
            project_id=api_key,
            base_url=ApiUrls.preprod.value
        )
        print("   ✅ Blockfrost API initialized")
        
        # Test health check
        print("2. Testing health endpoint...")
        health = api.health()
        print(f"   ✅ Health check: {health}")
        
        # Test network info
        print("3. Testing network information...")
        network = api.network()
        print(f"   ✅ Network info: Circulating supply: {network.supply.circulating}")
        
        # Test latest block
        print("4. Testing latest block...")
        latest_block = api.block_latest()
        print(f"   ✅ Latest block: Height {latest_block.height}, Time {latest_block.time}")
        
        # Test protocol parameters
        print("5. Testing protocol parameters...")
        params = api.epoch_latest_parameters()
        print(f"   ✅ Protocol params: min_fee_a={params.min_fee_a}, min_utxo={params.min_utxo}")
        
        return True
        
    except ApiError as e:
        print(f"   ❌ Blockfrost API error: {e}")
        return False
    except Exception as e:
        print(f"   ❌ Blockfrost connectivity test failed: {e}")
        return False


def test_pycardano_imports():
    """Test PyCardano imports and basic functionality"""
    print("\n=== TESTING PYCARDANO IMPORTS ===")
    
    try:
        # Test core imports
        print("1. Testing core PyCardano imports...")
        from pycardano import (
            Address, 
            Network, 
            TransactionBuilder, 
            PlutusV2Script,
            script_hash,
            ScriptRef
        )
        print("   ✅ Core PyCardano imports successful")
        
        # Test address creation
        print("2. Testing address functionality...")
        # Create a simple address for testing
        from pycardano import PaymentVerificationKey, PaymentSigningKey
        signing_key = PaymentSigningKey.generate()
        verification_key = PaymentVerificationKey.from_signing_key(signing_key)
        address = Address(verification_key.hash(), network=Network.TESTNET)
        print(f"   ✅ Address created: {str(address)[:50]}...")
        
        # Test network enum
        print("3. Testing network configuration...")
        testnet = Network.TESTNET
        print(f"   ✅ Network: {testnet}")
        
        return True
        
    except ImportError as e:
        print(f"   ❌ PyCardano import error: {e}")
        return False
    except Exception as e:
        print(f"   ❌ PyCardano test failed: {e}")
        return False


def test_validator_integration():
    """Test integration with Aiken validator"""
    print("\n=== TESTING VALIDATOR INTEGRATION ===")
    
    try:
        # Load plutus.json
        print("1. Loading validator from plutus.json...")
        plutus_path = os.path.join(os.path.dirname(__file__), '..', 'plutus.json')
        with open(plutus_path, 'r') as f:
            plutus_data = json.load(f)
        
        validators = plutus_data.get('validators', [])
        print(f"   ✅ Found {len(validators)} validators")
        
        if validators:
            validator = validators[0]
            print(f"   ✅ First validator: {validator['title']}")
            print(f"   ✅ Hash: {validator['hash']}")
            
            # Test CBOR parsing
            print("2. Testing CBOR compilation...")
            cbor_hex = validator['compiledCode']
            cbor_bytes = bytes.fromhex(cbor_hex)
            print(f"   ✅ CBOR parsed: {len(cbor_bytes)} bytes")
            
            # Test script hash calculation
            print("3. Testing script hash...")
            from pycardano import PlutusV2Script, script_hash
            script = PlutusV2Script(cbor_bytes)
            calculated_hash = script_hash(script)
            expected_hash = validator['hash']
            
            print(f"   ✅ Calculated hash: {calculated_hash.hex()}")
            print(f"   ✅ Expected hash: {expected_hash}")
            print(f"   ✅ Hash match: {calculated_hash.hex() == expected_hash}")
            
            # Test script address generation
            print("4. Testing script address generation...")
            from pycardano import Address, Network
            script_address = Address(calculated_hash, network=Network.TESTNET)
            print(f"   ✅ Script address: {str(script_address)}")
            
        return True
        
    except Exception as e:
        print(f"   ❌ Validator integration test failed: {e}")
        return False


def test_blockfrost_chain_context():
    """Test PyCardano with Blockfrost chain context"""
    print("\n=== TESTING CHAIN CONTEXT ===")
    
    try:
        print("1. Creating Blockfrost chain context...")
        from pycardano import BlockFrostChainContext, Network
        
        context = BlockFrostChainContext(
            project_id="preprodb51DvdEdGkJgVmx1CNnR2EEfWrDtifLR",
            network=Network.TESTNET
        )
        print("   ✅ Chain context created")
        
        # Test protocol parameters query
        print("2. Testing protocol parameters query...")
        protocol_params = context.protocol_param
        print(f"   ✅ Protocol params loaded: min_fee_a={protocol_params.min_fee_a}")
        
        return True
        
    except Exception as e:
        print(f"   ❌ Chain context test failed: {e}")
        return False


def main():
    print("🐍 PYCARDANO AND BLOCKFROST CONNECTIVITY TEST")
    print("=============================================")
    
    results = {
        'blockfrost': False,
        'pycardano': False,
        'validator': False,
        'context': False
    }
    
    # Run all tests
    results['blockfrost'] = test_blockfrost_connectivity()
    results['pycardano'] = test_pycardano_imports()
    results['validator'] = test_validator_integration()
    results['context'] = test_blockfrost_chain_context()
    
    # Summary
    print("\n=== TEST RESULTS SUMMARY ===")
    print(f"Blockfrost API: {'✅ PASS' if results['blockfrost'] else '❌ FAIL'}")
    print(f"PyCardano SDK: {'✅ PASS' if results['pycardano'] else '❌ FAIL'}")
    print(f"Validator Integration: {'✅ PASS' if results['validator'] else '❌ FAIL'}")
    print(f"Chain Context: {'✅ PASS' if results['context'] else '❌ FAIL'}")
    
    all_passed = all(results.values())
    print(f"\nOverall Status: {'✅ ALL TESTS PASSED' if all_passed else '❌ SOME TESTS FAILED'}")
    
    if all_passed:
        print("\n🎉 PyCardano integration is ready for deployment testing!")
        print("✅ Can compile and hash validators")
        print("✅ Can generate script addresses") 
        print("✅ Can connect to Blockfrost API")
        print("✅ Can create chain context for transactions")
    else:
        print("\n🔧 Some issues need to be resolved before deployment testing.")
    
    return 0 if all_passed else 1


if __name__ == "__main__":
    sys.exit(main())



