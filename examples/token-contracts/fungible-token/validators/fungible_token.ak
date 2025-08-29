// ❌ WARNING: EDUCATIONAL EXAMPLE ONLY - NOT PRODUCTION READY
// 
// 🚨 CRITICAL: DO NOT DEPLOY TO MAINNET
// This validator contains placeholder security that WILL NOT protect your funds
//
// ISSUES:
// ❌ Admin signature validation hardcoded to `True` - ANYONE CAN MINT
// ❌ No actual transaction context validation
// ❌ Allows unlimited minting by any user
// ❌ Claims "controlled minting" but has no controls
//
// STATUS: Example for learning concepts only - requires complete rewrite for production

// Redeemer defines possible actions for the fungible token
pub type Action {
  Mint { amount: Int }
  Burn { amount: Int }
}

// Parameterized with admin's public key hash for controlled minting
validator fungible_token(_admin_pkh: ByteArray) {
  mint(_redeemer: Action, _datum: Void, _context: __ScriptContext) {
    // 🚨 CIRCUIT BREAKER: Prevent accidental mainnet deployment
    fail @"SECURITY BREACH: This token validator is NOT production ready. Admin signature validation is disabled - ANYONE CAN MINT unlimited tokens. DO NOT DEPLOY to mainnet. See SECURITY_STATUS.md for safe alternatives."
  }

  else(_) {
    fail
  }
}
