use nft_policy/helpers

// Basic test for the NFT policy
test nft_policy_basic_test() {
  True
}

// Test the minting quantity validation
test validate_mint_quantity_test() {
  helpers.validate_mint_quantity(1)
}

// Test that invalid quantities are rejected
test validate_mint_quantity_rejects_invalid() {
  !helpers.validate_mint_quantity(0) && !helpers.validate_mint_quantity(2)
}

// Test the burning validation
test validate_burn_test() {
  helpers.validate_burn(-1)
}

// Test that positive quantities are not considered burning
test validate_burn_rejects_positive() {
  !helpers.validate_burn(1) && !helpers.validate_burn(0)
}

// Test the one-shot minting validation
test validate_one_shot_mint_test() {
  helpers.validate_one_shot_mint(1)
}
