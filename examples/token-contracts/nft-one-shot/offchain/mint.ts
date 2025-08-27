// NFT One-Shot Minting Script using MeshJS
// This script demonstrates how to mint an NFT using the one-shot policy

import { 
  ForgeScript, 
  Transaction, 
  Address, 
  Assets, 
  MintingPolicy,
  PolicyId,
  AssetName,
  UTxO,
  WalletApi,
  ForgeScriptWithUTxO
} from '@meshsdk/core';

// Configuration
const NETWORK = 'preprod'; // or 'mainnet'
const TOKEN_NAME = 'MyUniqueNFT';
const REFERENCE_UTXO_AMOUNT = 1000000; // 1 ADA in lovelace

// NFT One-Shot Minting Policy Parameters
interface NftPolicyParams {
  issuer: string;           // VerifierKeyHash as hex string
  referenceUtxo: string;    // UTxO ID as hex string
  tokenName: string;        // Token name
  validFrom: number;        // Slot number
  validUntil: number;       // Slot number
}

// Redeemer for minting
interface NftMintRedeemer {
  quantity: number;         // Must be exactly 1
}

/**
 * Create NFT One-Shot Minting Policy
 * This creates a policy that can only mint exactly one NFT once
 */
export async function createNftOneShotPolicy(
  wallet: WalletApi,
  params: NftPolicyParams
): Promise<MintingPolicy> {
  
  // Create the policy script
  const policyScript = `
    // NFT One-Shot Minting Policy
    // This policy ensures exactly one NFT can be minted once
    
    use aiken/transaction.{ScriptContext, Transaction}
    use aiken/transaction/credential.{VerifierKeyHash}
    use aiken/bytearray.{ByteArray}
    use aiken/list.{List}
    use aiken/int.{Int}
    
    // Policy parameters
    type NftPolicyParams {
      issuer: VerifierKeyHash,
      reference_utxo: ByteArray,
      token_name: ByteArray,
      valid_from: Int,
      valid_until: Int,
    }
    
    // Redeemer
    type NftMintRedeemer {
      quantity: Int,
    }
    
    // Main policy function
    pub fn nft_mint_policy(
      params: NftPolicyParams,
      redeemer: NftMintRedeemer,
      context: ScriptContext,
    ) -> Bool {
      let tx = context.transaction
      
      // 1. Validate quantity (exactly one)
      let valid_quantity = redeemer.quantity == 1
      
      // 2. Check validity interval
      let valid_time = when tx.validity_range is {
        Finite(lower, upper) -> {
          lower >= params.valid_from && upper <= params.valid_until
        }
        _ -> False
      }
      
      // 3. Validate reference UTxO is consumed
      let reference_consumed = list.any(tx.inputs, fn(input) {
        input.output_id == params.reference_utxo
      })
      
      // 4. Check issuer signature
      let issuer_signed = tx.is_signed_by(params.issuer)
      
      // 5. Validate minted assets
      let minted_assets = tx.mint.assets
      let valid_mint = list.length(minted_assets) == 1 && {
        let asset = list.at(minted_assets, 0).expect("Should have exactly one asset")
        asset.quantity == 1 && asset.asset_name == params.token_name
      }
      
      valid_quantity && valid_time && reference_consumed && issuer_signed && valid_mint
    }
  `;
  
  // Create the minting policy
  const policy: MintingPolicy = {
    type: 'Native',
    script: policyScript,
    // Note: In a real implementation, you would compile this with Aiken
    // and use the compiled script hash
  };
  
  return policy;
}

/**
 * Mint NFT using One-Shot Policy
 */
export async function mintNftOneShot(
  wallet: WalletApi,
  policyId: PolicyId,
  assetName: AssetName,
  referenceUtxo: UTxO,
  validFrom: number,
  validUntil: number
): Promise<Transaction> {
  
  // Create the minting policy parameters
  const policyParams: NftPolicyParams = {
    issuer: await wallet.getRewardAddresses()[0], // Use wallet's stake key
    referenceUtxo: referenceUtxo.input.txHash + referenceUtxo.input.outputIndex.toString(),
    tokenName: assetName,
    validFrom: validFrom,
    validUntil: validUntil,
  };
  
  // Create the redeemer
  const redeemer: NftMintRedeemer = {
    quantity: 1
  };
  
  // Create the transaction
  const tx = new Transaction({ initiator: wallet })
    .mintAssets(
      policyId,
      [{ assetName: assetName, quantity: 1 }]
    )
    .sendAssets(
      await wallet.getChangeAddress(),
      [{ assetName: assetName, quantity: 1 }]
    )
    .setRequiredSigners([policyParams.issuer])
    .setValidityRange(validFrom, validUntil);
  
  // Add the reference UTxO as input
  tx.setTxIn(referenceUtxo.input.txHash, referenceUtxo.input.outputIndex);
  
  return tx;
}

/**
 * Example usage function
 */
export async function mintNftExample(wallet: WalletApi): Promise<void> {
  try {
    console.log('🚀 Starting NFT One-Shot Minting...');
    
    // Get current slot
    const currentSlot = await wallet.getLatestBlock();
    const validFrom = currentSlot + 1;
    const validUntil = currentSlot + 1000; // 1000 slots window
    
    // Create a reference UTxO (in practice, this would be a specific UTxO)
    const referenceUtxo: UTxO = {
      input: {
        txHash: '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
        outputIndex: 0
      },
      output: {
        address: await wallet.getChangeAddress(),
        amount: [{ unit: 'lovelace', quantity: REFERENCE_UTXO_AMOUNT.toString() }]
      }
    };
    
    // Create policy ID (in practice, this would be derived from the compiled script)
    const policyId: PolicyId = '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';
    
    // Create asset name
    const assetName: AssetName = TOKEN_NAME;
    
    // Mint the NFT
    const tx = await mintNftOneShot(
      wallet,
      policyId,
      assetName,
      referenceUtxo,
      validFrom,
      validUntil
    );
    
    // Sign and submit the transaction
    const signedTx = await tx.sign();
    const txHash = await signedTx.submit();
    
    console.log('✅ NFT minted successfully!');
    console.log('📄 Transaction hash:', txHash);
    console.log('🪙 Policy ID:', policyId);
    console.log('🏷️ Asset name:', assetName);
    
  } catch (error) {
    console.error('❌ Error minting NFT:', error);
    throw error;
  }
}

// Export for use in other modules
export { NftPolicyParams, NftMintRedeemer };
