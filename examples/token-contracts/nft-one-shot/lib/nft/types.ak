// 🏗️ NFT TYPE DEFINITIONS
// 
// This module defines all types used in the NFT one-shot minting system.
// These types ensure type safety and clear interfaces.

/// Actions that can be performed with this minting policy
pub type NftAction {
  /// Mint exactly one NFT token
  Mint { 
    /// Name of the NFT token (must be non-empty)
    token_name: ByteArray 
  }
  /// Burn NFT token (anyone can burn tokens they own)
  Burn { 
    /// Name of the NFT token to burn
    token_name: ByteArray 
  }
}
