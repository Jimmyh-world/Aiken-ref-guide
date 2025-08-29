// 🏗️ FUNGIBLE TOKEN TYPE DEFINITIONS
// 
// This module defines all types used in the controlled fungible token system.
// These types ensure type safety and real admin control validation.

/// Actions that can be performed with this fungible token policy
pub type TokenAction {
  /// Mint fungible tokens (requires admin signature)
  Mint { 
    /// Name of the token to mint
    token_name: ByteArray,
    /// Amount to mint (must be positive)
    amount: Int
  }
  /// Burn fungible tokens (anyone can burn their own tokens)
  Burn { 
    /// Name of the token to burn
    token_name: ByteArray,
    /// Amount to burn (must be negative)
    amount: Int
  }
}
