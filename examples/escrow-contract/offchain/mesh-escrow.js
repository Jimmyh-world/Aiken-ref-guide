/**
 * Escrow Contract Integration with Mesh.js
 * 
 * Complete example showing how to interact with the Aiken escrow contract
 * using Mesh.js for transaction building and wallet integration.
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
  Action,
  UTxO,
  Asset,
  PlutusScript,
  Data,
  resolveDataHash,
  resolvePaymentKeyHash,
  serializePlutusScript,
} from '@meshsdk/core';

// Configuration - Update for your environment
const BLOCKFROST_API_KEY = process.env.BLOCKFROST_API_KEY || 'YOUR_API_KEY';
const NETWORK = 'testnet'; // or 'mainnet'

/**
 * Escrow Contract Class
 * Handles all interactions with the Aiken escrow smart contract
 */
class EscrowContract {
  constructor(provider, wallet) {
    this.provider = provider;
    this.wallet = wallet;
    this.escrowScript = this.loadEscrowScript();
  }

  /**
   * Load the compiled Aiken escrow script
   * In production, load from plutus.json
   */
  loadEscrowScript() {
    // This would load from ../plutus.json in real implementation
    return {
      code: "590a4d590a4a0100003...", // Compiled plutus script
      version: "V2"
    };
  }

  /**
   * Create Escrow Datum
   * Constructs the datum required for escrow transactions
   */
  createEscrowDatum(buyer, seller, amount, deadline, nonce) {
    return Data.to({
      buyer: buyer,
      seller: seller,
      amount: BigInt(amount),
      deadline: BigInt(deadline),
      nonce: BigInt(nonce),
      state: { Active: {} }, // EscrowState::Active
    });
  }

  /**
   * Create Escrow Redeemer
   * Constructs redeemer for different escrow actions
   */
  createEscrowRedeemer(action) {
    switch (action) {
      case 'complete':
        return Data.to({ CompleteEscrow: {} });
      case 'cancel':
        return Data.to({ CancelEscrow: {} });
      case 'refund':
        return Data.to({ RefundEscrow: {} });
      default:
        throw new Error(`Unknown escrow action: ${action}`);
    }
  }

  /**
   * Lock Funds in Escrow
   * Creates a transaction that locks ADA in the escrow contract
   */
  async lockFunds(sellerAddress, amount, deadlineHours = 24) {
    try {
      const buyerKeyHash = resolvePaymentKeyHash(await this.wallet.getChangeAddress());
      const sellerKeyHash = resolvePaymentKeyHash(sellerAddress);
      
      // Calculate deadline (hours from now)
      const deadline = Math.floor(Date.now() / 1000) + (deadlineHours * 3600);
      
      // Create unique nonce
      const nonce = Math.floor(Math.random() * 1000000);
      
      // Create escrow datum
      const escrowDatum = this.createEscrowDatum(
        buyerKeyHash,
        sellerKeyHash,
        amount,
        deadline,
        nonce
      );

      // Get escrow script address
      const escrowAddress = serializePlutusScript(this.escrowScript).address;

      // Build transaction
      const tx = new Transaction({ initiator: this.wallet })
        .sendLovelace(escrowAddress, amount.toString())
        .sendAssets(escrowAddress, [], escrowDatum);

      // Sign and submit
      const unsignedTx = await tx.build();
      const signedTx = await this.wallet.signTx(unsignedTx);
      const txHash = await this.wallet.submitTx(signedTx);

      console.log(`✅ Escrow created! Transaction hash: ${txHash}`);
      console.log(`📋 Escrow details:`);
      console.log(`   - Amount: ${amount / 1000000} ADA`);
      console.log(`   - Deadline: ${new Date(deadline * 1000).toISOString()}`);
      console.log(`   - Nonce: ${nonce}`);
      
      return {
        txHash,
        datum: escrowDatum,
        deadline,
        nonce
      };

    } catch (error) {
      console.error('❌ Failed to lock funds in escrow:', error);
      throw error;
    }
  }

  /**
   * Complete Escrow Transaction
   * Releases funds to seller and returns any change to buyer
   */
  async completeEscrow(escrowUtxo, originalDatum) {
    try {
      const redeemer = this.createEscrowRedeemer('complete');
      
      // Build completion transaction
      const tx = new Transaction({ initiator: this.wallet })
        .redeemValue({
          value: escrowUtxo,
          script: this.escrowScript,
          datum: originalDatum,
          redeemer: redeemer,
        });

      // Add validation range (must be before deadline)
      const currentTime = Math.floor(Date.now() / 1000);
      tx.validFrom(currentTime).validTo(currentTime + 900); // 15 minute window

      // Sign and submit
      const unsignedTx = await tx.build();
      const signedTx = await this.wallet.signTx(unsignedTx);
      const txHash = await this.wallet.submitTx(signedTx);

      console.log(`✅ Escrow completed! Transaction hash: ${txHash}`);
      return txHash;

    } catch (error) {
      console.error('❌ Failed to complete escrow:', error);
      throw error;
    }
  }

  /**
   * Cancel Escrow Transaction
   * Returns funds to buyer before deadline
   */
  async cancelEscrow(escrowUtxo, originalDatum) {
    try {
      const redeemer = this.createEscrowRedeemer('cancel');
      
      // Build cancellation transaction
      const tx = new Transaction({ initiator: this.wallet })
        .redeemValue({
          value: escrowUtxo,
          script: this.escrowScript,
          datum: originalDatum,
          redeemer: redeemer,
        });

      // Add validation range (must be before deadline)
      const currentTime = Math.floor(Date.now() / 1000);
      tx.validFrom(currentTime).validTo(currentTime + 900);

      // Sign and submit
      const unsignedTx = await tx.build();
      const signedTx = await this.wallet.signTx(unsignedTx);
      const txHash = await this.wallet.submitTx(signedTx);

      console.log(`✅ Escrow cancelled! Transaction hash: ${txHash}`);
      return txHash;

    } catch (error) {
      console.error('❌ Failed to cancel escrow:', error);
      throw error;
    }
  }

  /**
   * Find Escrow UTxOs
   * Searches for escrow contracts at the script address
   */
  async findEscrowUtxos() {
    try {
      const scriptAddress = serializePlutusScript(this.escrowScript).address;
      const utxos = await this.provider.fetchAddressUTxOs(scriptAddress);
      
      return utxos.filter(utxo => utxo.output.plutusData); // Has datum
    } catch (error) {
      console.error('❌ Failed to find escrow UTxOs:', error);
      throw error;
    }
  }
}

/**
 * Example Usage
 * Demonstrates complete escrow workflow
 */
async function exampleUsage() {
  try {
    // Initialize provider and wallet
    const provider = new BlockfrostProvider(BLOCKFROST_API_KEY);
    const wallet = await MeshWallet.restore({
      mnemonic: process.env.WALLET_MNEMONIC || 'your twelve word mnemonic here',
      network: NETWORK,
    });

    // Create escrow instance
    const escrow = new EscrowContract(provider, wallet);

    console.log('🚀 Starting Escrow Example...\n');

    // Example 1: Lock funds in escrow
    console.log('📝 Step 1: Locking 5 ADA in escrow...');
    const sellerAddress = 'addr_test1...'; // Replace with actual address
    const amount = 5_000_000; // 5 ADA in Lovelace
    
    const lockResult = await escrow.lockFunds(sellerAddress, amount, 24);
    
    // Wait for confirmation
    console.log('\n⏳ Waiting for transaction confirmation...');
    await new Promise(resolve => setTimeout(resolve, 30000));

    // Example 2: Find the escrow
    console.log('\n🔍 Step 2: Finding escrow UTxO...');
    const escrowUtxos = await escrow.findEscrowUtxos();
    console.log(`Found ${escrowUtxos.length} escrow UTxOs`);

    // Example 3: Complete the escrow (optional)
    if (escrowUtxos.length > 0) {
      console.log('\n✅ Step 3: Completing escrow...');
      await escrow.completeEscrow(escrowUtxos[0], lockResult.datum);
    }

    console.log('\n🎉 Escrow example completed successfully!');

  } catch (error) {
    console.error('\n💥 Example failed:', error);
  }
}

/**
 * Utility Functions
 */

// Convert Lovelace to ADA
function lovelaceToAda(lovelace) {
  return (lovelace / 1_000_000).toFixed(6);
}

// Convert ADA to Lovelace  
function adaToLovelace(ada) {
  return Math.floor(ada * 1_000_000);
}

// Format deadline for display
function formatDeadline(timestamp) {
  return new Date(timestamp * 1000).toLocaleString();
}

/**
 * CLI Interface
 * Run different escrow operations from command line
 */
if (import.meta.url === new URL(process.argv[1], 'file:').href) {
  const command = process.argv[2];
  
  switch (command) {
    case 'example':
      exampleUsage();
      break;
    case 'lock':
      // node mesh-escrow.js lock <seller-address> <amount-ada> <deadline-hours>
      console.log('Implement lock command...');
      break;
    case 'complete':
      // node mesh-escrow.js complete <tx-hash>
      console.log('Implement complete command...');
      break;
    case 'cancel':
      // node mesh-escrow.js cancel <tx-hash>
      console.log('Implement cancel command...');
      break;
    default:
      console.log('Usage: node mesh-escrow.js [example|lock|complete|cancel]');
  }
}

export { EscrowContract, lovelaceToAda, adaToLovelace, formatDeadline };
