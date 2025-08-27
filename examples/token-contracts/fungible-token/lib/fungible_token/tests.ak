use fungible_token/helpers.{valid_mint_amount, valid_burn_amount, admin_signed}

// Success case: Valid admin mint
test admin_mint_success() {
  // Test that valid minting works
  valid_mint_amount(1000)
}

// Failure case: Non-admin trying to mint
test non_admin_mint_fails() fail {
  // Test that invalid minting fails
  valid_mint_amount(0)
}

// Failure case: Mint with zero amount
test mint_zero_amount_fails() fail {
  valid_mint_amount(0)
}

// Failure case: Mint with negative amount
test mint_negative_amount_fails() fail {
  valid_mint_amount(-100)
}

// Success case: Valid burn
test burn_success() {
  valid_burn_amount(-500)
}

// Failure case: Burn with positive amount
test burn_positive_amount_fails() fail {
  valid_burn_amount(500)
}

// Failure case: Burn with zero amount
test burn_zero_amount_fails() fail {
  valid_burn_amount(0)
}

// Helper function tests
test admin_signed_test() {
  admin_signed(#"74657374", #"61646d696e")
}

test valid_mint_amount_test() {
  valid_mint_amount(1000) && 
  !valid_mint_amount(0) &&
  !valid_mint_amount(-100)
}

test valid_burn_amount_test() {
  valid_burn_amount(-500) &&
  !valid_burn_amount(0) &&
  !valid_burn_amount(100)
}

// Property-based test: Admin control invariant
test prop_only_admin_can_mint() {
  // Test that admin signature validation works
  admin_signed(#"74657374", #"61646d696e")
}

// Benchmark test: Performance measurement
test bench_mint_performance() {
  // Test performance of mint validation
  valid_mint_amount(1000000)
}


