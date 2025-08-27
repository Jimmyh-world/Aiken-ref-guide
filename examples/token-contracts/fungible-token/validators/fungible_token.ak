// Redeemer defines possible actions for the fungible token
pub type Action {
  Mint { amount: Int }
  Burn { amount: Int }
}

// Parameterized with admin's public key hash for controlled minting
validator fungible_token(_admin_pkh: ByteArray) {
  mint(redeemer: Action, _datum: Void, _context: __ScriptContext) -> Bool {
    when redeemer is {
      Mint { amount } -> {
        // 1. Check admin signature in transaction (simplified for demo)
        let admin_signed = True // TODO: Implement proper signature validation
        
        // 2. Validate positive amount for minting
        let positive_amount = amount > 0
        
        and {
          admin_signed,
          positive_amount,
        }
      }
      Burn { amount } -> {
        // Allow unrestricted burning - ledger ensures token ownership
        // Amount must be negative for burning
        amount < 0
      }
    }
  }
}
