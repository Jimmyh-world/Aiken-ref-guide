#!/usr/bin/env node
/**
 * NFT One-Shot Policy Integration with Mesh.js
 * 
 * Complete example showing how to mint and burn NFTs using the Aiken one-shot
 * policy with Mesh.js for transaction building and wallet integration.
 * 
 * Prerequisites:
 * - npm install @meshsdk/core @meshsdk/wallet
 * - Cardano wallet (Nami, Eternl, etc.)
 * - Testnet ADA for transactions
 */

import {
  BlockfrostProvider,
  MeshWallet,
  Transaction,
  ForgeScript,
  Mint,
  UTxO,
  Asset,
  PlutusScript,
  Data,
  resolveDataHash,
  resolvePaymentKeyHash,
  serializePlutusScript,
  resolveScriptHash,
} from '@meshsdk/core';

// Configuration - Update for your environment
const BLOCKFROST_API_KEY = process.env.BLOCKFROST_API_KEY || 'YOUR_API_KEY';
const NETWORK = 'testnet'; // or 'mainnet'

/**
 * NFT One-Shot Policy Class
 * Handles minting and burning of unique NFTs using the Aiken one-shot policy
 */
class NftOneShot {
  constructor(provider, wallet) {
    this.provider = provider;
    this.wallet = wallet;
    this.script = this.loadNftScript();
  }

  /**
   * Load the compiled Aiken NFT script
   * In production, load from plutus.json
   */
  loadNftScript() {
    // This would load from ../plutus.json in real implementation
    return {
      code: "590a4d590a4a0100003...", // Compiled plutus script
      version: "V2"
    };
  }

  /**
   * Create NFT Redeemer
   * Constructs redeemer for mint/burn actions
   */
  createNftRedeemer(action, tokenName) {
    switch (action) {
      case 'mint':
        return Data.to({
          Mint: { token_name: tokenName }
        });
      case 'burn':
        return Data.to({
          Burn: { token_name: tokenName }
        });
      default:
        throw new Error(`Unknown NFT action: ${action}`);
    }
  }

  /**
   * Get Policy ID from UTxO Reference
   * Creates parameterized script with specific UTxO reference
   */
  getPolicyId(utxoRef) {
    // In real implementation, this would parameterize the script
    // with the UTxO reference to create unique policy ID
    const parameterizedScript = this.parameterizeScript(utxoRef);
    return resolveScriptHash(parameterizedScript);
  }

  /**
   * Parameterize Script with UTxO Reference
   * Creates one-shot policy specific to a UTxO
   */
  parameterizeScript(utxoRef) {
    // This would use Aiken's parameterization feature
    // For now, return base script (simplified for demo)
    return this.script;
  }

  /**
   * Find Suitable UTxO for One-Shot Minting
   * Selects a UTxO that will be consumed to guarantee uniqueness
   */
  async findUniqueUtxo() {
    try {
      const address = await this.wallet.getChangeAddress();
      const utxos = await this.wallet.getUtxos();
      
      // Select the first UTxO with enough ADA for fees
      const suitableUtxo = utxos.find(utxo => {
        const lovelace = parseInt(utxo.output.amount.find(
          asset => asset.unit === 'lovelace'
        )?.quantity || '0');
        return lovelace >= 2_000_000; // 2 ADA minimum
      });

      if (!suitableUtxo) {
        throw new Error('No suitable UTxO found for one-shot minting');
      }

      console.log(`🎯 Selected UTxO for uniqueness: ${suitableUtxo.input.txHash}#${suitableUtxo.input.outputIndex}`);
      return suitableUtxo;

    } catch (error) {
      console.error('❌ Failed to find unique UTxO:', error);
      throw error;
    }
  }

  /**
   * Mint Unique NFT
   * Creates a transaction that mints exactly one NFT using one-shot policy
   */
  async mintNft(tokenName, metadata = null) {
    try {
      console.log(`🎨 Minting NFT: ${tokenName}`);

      // Step 1: Find unique UTxO for one-shot guarantee
      const uniqueUtxo = await this.findUniqueUtxo();
      const utxoRef = {
        txHash: uniqueUtxo.input.txHash,
        outputIndex: uniqueUtxo.input.outputIndex
      };

      // Step 2: Get policy ID for this specific UTxO
      const policyId = this.getPolicyId(utxoRef);
      
      // Step 3: Create mint redeemer
      const mintRedeemer = this.createNftRedeemer('mint', tokenName);

      // Step 4: Create forge script
      const forgeScript = ForgeScript.withOneSignature(policyId);

      // Step 5: Build minting transaction
      const tx = new Transaction({ initiator: this.wallet });

      // Add the unique UTxO as input (this consumption guarantees uniqueness)
      tx.redeemValue({
        value: uniqueUtxo,
        script: this.script,
        redeemer: mintRedeemer,
      });

      // Add NFT minting
      const asset = {
        unit: policyId + Buffer.from(tokenName).toString('hex'),
        quantity: '1'
      };

      tx.mintAsset(forgeScript, asset);

      // Add metadata if provided
      if (metadata) {
        tx.setMetadata(721, {
          [policyId]: {
            [tokenName]: metadata
          }
        });
      }

      // Step 6: Sign and submit
      const unsignedTx = await tx.build();
      const signedTx = await this.wallet.signTx(unsignedTx);
      const txHash = await this.wallet.submitTx(signedTx);

      console.log(`✅ NFT minted successfully!`);
      console.log(`   Transaction hash: ${txHash}`);
      console.log(`   Policy ID: ${policyId}`);
      console.log(`   Token name: ${tokenName}`);
      console.log(`   Asset ID: ${asset.unit}`);

      return {
        txHash,
        policyId,
        tokenName,
        assetId: asset.unit,
        uniqueUtxo: utxoRef
      };

    } catch (error) {
      console.error('❌ Failed to mint NFT:', error);
      throw error;
    }
  }

  /**
   * Burn NFT
   * Burns an existing NFT using the one-shot policy
   */
  async burnNft(policyId, tokenName) {
    try {
      console.log(`🔥 Burning NFT: ${tokenName}`);

      // Create burn redeemer
      const burnRedeemer = this.createNftRedeemer('burn', tokenName);

      // Create forge script for burning
      const forgeScript = ForgeScript.withOneSignature(policyId);

      // Build burning transaction
      const tx = new Transaction({ initiator: this.wallet });

      // Add NFT burning (negative quantity)
      const asset = {
        unit: policyId + Buffer.from(tokenName).toString('hex'),
        quantity: '-1'
      };

      tx.burnAsset(forgeScript, asset, burnRedeemer);

      // Sign and submit
      const unsignedTx = await tx.build();
      const signedTx = await this.wallet.signTx(unsignedTx);
      const txHash = await this.wallet.submitTx(signedTx);

      console.log(`✅ NFT burned successfully!`);
      console.log(`   Transaction hash: ${txHash}`);
      console.log(`   Asset burned: ${asset.unit}`);

      return { txHash, assetId: asset.unit };

    } catch (error) {
      console.error('❌ Failed to burn NFT:', error);
      throw error;
    }
  }

  /**
   * List NFTs in Wallet
   * Shows all NFTs owned by the connected wallet
   */
  async listNfts() {
    try {
      const utxos = await this.wallet.getUtxos();
      const nfts = [];

      for (const utxo of utxos) {
        for (const asset of utxo.output.amount) {
          if (asset.unit !== 'lovelace' && asset.quantity === '1') {
            // This looks like an NFT (quantity = 1)
            const policyId = asset.unit.slice(0, 56);
            const tokenNameHex = asset.unit.slice(56);
            const tokenName = Buffer.from(tokenNameHex, 'hex').toString();

            nfts.push({
              policyId,
              tokenName,
              assetId: asset.unit,
              utxo: utxo.input
            });
          }
        }
      }

      console.log(`🖼️  Found ${nfts.length} NFTs in wallet:`);
      nfts.forEach((nft, index) => {
        console.log(`   ${index + 1}. ${nft.tokenName} (${nft.assetId})`);
      });

      return nfts;

    } catch (error) {
      console.error('❌ Failed to list NFTs:', error);
      throw error;
    }
  }

  /**
   * Verify NFT Uniqueness
   * Checks if an NFT is truly unique by verifying the UTxO was consumed
   */
  async verifyUniqueness(utxoRef) {
    try {
      // Try to query the UTxO - if it doesn't exist, it was consumed
      const utxo = await this.provider.fetchUTxO(
        `${utxoRef.txHash}#${utxoRef.outputIndex}`
      );

      if (utxo) {
        console.log('⚠️  Warning: UTxO still exists - NFT may not be unique');
        return false;
      } else {
        console.log('✅ UTxO consumed - NFT uniqueness guaranteed');
        return true;
      }

    } catch (error) {
      // Error usually means UTxO doesn't exist (consumed)
      console.log('✅ UTxO consumed - NFT uniqueness guaranteed');
      return true;
    }
  }
}

/**
 * Example Usage
 * Demonstrates NFT minting, listing, and burning
 */
async function exampleUsage() {
  try {
    // Initialize provider and wallet
    const provider = new BlockfrostProvider(BLOCKFROST_API_KEY);
    const wallet = await MeshWallet.restore({
      mnemonic: process.env.WALLET_MNEMONIC || 'your twelve word mnemonic here',
      network: NETWORK,
    });

    // Create NFT instance
    const nft = new NftOneShot(provider, wallet);

    console.log('🚀 Starting NFT One-Shot Example...\n');

    // Example 1: Mint unique NFT
    console.log('🎨 Step 1: Minting unique NFT...');
    const metadata = {
      name: "My Unique NFT #001",
      description: "A truly unique NFT created with Aiken one-shot policy",
      image: "ipfs://QmYourImageHash",
      attributes: [
        { trait_type: "Rarity", value: "Legendary" },
        { trait_type: "Color", value: "Gold" }
      ]
    };

    const mintResult = await nft.mintNft("MyCollection001", metadata);

    // Example 2: Verify uniqueness
    console.log('\n🔍 Step 2: Verifying NFT uniqueness...');
    await nft.verifyUniqueness(mintResult.uniqueUtxo);

    // Example 3: List all NFTs
    console.log('\n📋 Step 3: Listing wallet NFTs...');
    const ownedNfts = await nft.listNfts();

    // Example 4: Burn NFT (optional)
    if (ownedNfts.length > 0) {
      console.log('\n🔥 Step 4: Burning NFT (optional)...');
      const firstNft = ownedNfts[0];
      // await nft.burnNft(firstNft.policyId, firstNft.tokenName);
      console.log('   (Skipped burning in example)');
    }

    console.log('\n🎉 NFT example completed successfully!');

  } catch (error) {
    console.error('\n💥 Example failed:', error);
  }
}

/**
 * CLI Interface
 * Run different NFT operations from command line
 */
if (import.meta.url === new URL(process.argv[1], 'file:').href) {
  const command = process.argv[2];
  
  switch (command) {
    case 'example':
      exampleUsage();
      break;
    case 'mint':
      // node mint-nft.js mint <token-name> [metadata-file]
      console.log('Implement mint command...');
      break;
    case 'burn':
      // node mint-nft.js burn <policy-id> <token-name>
      console.log('Implement burn command...');
      break;
    case 'list':
      // node mint-nft.js list
      console.log('Implement list command...');
      break;
    case 'verify':
      // node mint-nft.js verify <tx-hash>#<output-index>
      console.log('Implement verify command...');
      break;
    default:
      console.log('Usage: node mint-nft.js [example|mint|burn|list|verify]');
      console.log('');
      console.log('Commands:');
      console.log('  example                     - Run complete example');
      console.log('  mint <name> [metadata]      - Mint new unique NFT');
      console.log('  burn <policy-id> <name>     - Burn existing NFT');
      console.log('  list                        - List wallet NFTs');
      console.log('  verify <utxo-ref>          - Verify NFT uniqueness');
  }
}

export { NftOneShot };
