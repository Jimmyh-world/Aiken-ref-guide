// Helper function to validate minting quantity
pub fn validate_mint_quantity(quantity: Int) -> Bool {
  quantity == 1
}

// Helper function to validate burning
pub fn validate_burn(quantity: Int) -> Bool {
  quantity < 0
}

// Helper function to validate one-shot NFT minting
pub fn validate_one_shot_mint(quantity: Int) -> Bool {
  validate_mint_quantity(quantity)
}
