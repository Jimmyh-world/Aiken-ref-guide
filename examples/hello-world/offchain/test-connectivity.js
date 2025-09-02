#!/usr/bin/env node

// Simple connectivity test for Mesh and Blockfrost
// Tests basic API connectivity without requiring wallet setup

const fetch = (...args) => import('node-fetch').then(({default: fetch}) => fetch(...args));

async function testBlockfrostConnectivity() {
    console.log('=== TESTING BLOCKFROST CONNECTIVITY ===');
    
    const apiKey = 'preprodb51DvdEdGkJgVmx1CNnR2EEfWrDtifLR';
    const baseUrl = 'https://cardano-preprod.blockfrost.io/api/v0';
    
    try {
        // Test 1: Health check
        console.log('1. Testing health endpoint...');
        const healthResponse = await fetch(`${baseUrl}/health`, {
            headers: { 'project_id': apiKey }
        });
        const healthData = await healthResponse.json();
        console.log('   ✅ Health check:', healthData);
        
        // Test 2: Network info
        console.log('2. Testing network endpoint...');
        const networkResponse = await fetch(`${baseUrl}/network`, {
            headers: { 'project_id': apiKey }
        });
        const networkData = await networkResponse.json();
        console.log('   ✅ Network info:', {
            circulating: networkData.supply?.circulating,
            live_stake: networkData.stake?.live
        });
        
        // Test 3: Latest block
        console.log('3. Testing latest block...');
        const blockResponse = await fetch(`${baseUrl}/blocks/latest`, {
            headers: { 'project_id': apiKey }
        });
        const blockData = await blockResponse.json();
        console.log('   ✅ Latest block:', {
            height: blockData.height,
            time: blockData.time,
            slot: blockData.slot
        });
        
        // Test 4: Protocol parameters
        console.log('4. Testing protocol parameters...');
        const paramsResponse = await fetch(`${baseUrl}/epochs/latest/parameters`, {
            headers: { 'project_id': apiKey }
        });
        const paramsData = await paramsResponse.json();
        console.log('   ✅ Protocol params:', {
            min_fee_a: paramsData.min_fee_a,
            min_fee_b: paramsData.min_fee_b,
            min_utxo: paramsData.min_utxo
        });
        
        return true;
    } catch (error) {
        console.error('   ❌ Blockfrost connectivity test failed:', error.message);
        return false;
    }
}

async function testMeshImports() {
    console.log('\n=== TESTING MESH IMPORTS ===');
    
    try {
        // Test importing core Mesh modules
        console.log('1. Testing @meshsdk/core imports...');
        const { BlockfrostProvider } = require('@meshsdk/core');
        console.log('   ✅ BlockfrostProvider imported successfully');
        
        // Test creating a provider instance
        console.log('2. Testing BlockfrostProvider instantiation...');
        const provider = new BlockfrostProvider('preprodb51DvdEdGkJgVmx1CNnR2EEfWrDtifLR');
        console.log('   ✅ BlockfrostProvider created successfully');
        
        // Test basic provider method
        console.log('3. Testing provider network query...');
        const networkInfo = await provider.fetchNetworkInfo();
        console.log('   ✅ Network query successful:', {
            network: networkInfo.network,
            epoch: networkInfo.epoch
        });
        
        return true;
    } catch (error) {
        console.error('   ❌ Mesh import test failed:', error.message);
        return false;
    }
}

async function testValidatorInfo() {
    console.log('\n=== TESTING VALIDATOR INFORMATION ===');
    
    try {
        // Read the plutus.json from the parent directory
        const fs = require('fs');
        const path = require('path');
        
        const plutusPath = path.join(__dirname, '..', 'plutus.json');
        const plutusContent = fs.readFileSync(plutusPath, 'utf8');
        const plutusData = JSON.parse(plutusContent);
        
        console.log('1. Plutus.json loaded successfully');
        console.log('   ✅ Validators found:', plutusData.validators.length);
        
        if (plutusData.validators.length > 0) {
            const validator = plutusData.validators[0];
            console.log('2. First validator info:');
            console.log('   ✅ Title:', validator.title);
            console.log('   ✅ Hash:', validator.hash);
            console.log('   ✅ CBOR length:', validator.compiledCode.length, 'chars');
        }
        
        return true;
    } catch (error) {
        console.error('   ❌ Validator info test failed:', error.message);
        return false;
    }
}

async function main() {
    console.log('🚀 MESH AND BLOCKFROST CONNECTIVITY TEST');
    console.log('========================================');
    
    const results = {
        blockfrost: false,
        mesh: false,
        validator: false
    };
    
    // Run all tests
    results.blockfrost = await testBlockfrostConnectivity();
    results.mesh = await testMeshImports();
    results.validator = await testValidatorInfo();
    
    // Summary
    console.log('\n=== TEST RESULTS SUMMARY ===');
    console.log('Blockfrost API:', results.blockfrost ? '✅ PASS' : '❌ FAIL');
    console.log('Mesh SDK:', results.mesh ? '✅ PASS' : '❌ FAIL');
    console.log('Validator Info:', results.validator ? '✅ PASS' : '❌ FAIL');
    
    const allPassed = Object.values(results).every(result => result);
    console.log('\nOverall Status:', allPassed ? '✅ ALL TESTS PASSED' : '❌ SOME TESTS FAILED');
    
    if (allPassed) {
        console.log('\n🎉 Mesh integration is ready for deployment testing!');
    } else {
        console.log('\n🔧 Some issues need to be resolved before deployment testing.');
    }
    
    process.exit(allPassed ? 0 : 1);
}

// Run the tests
main().catch(console.error);
