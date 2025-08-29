// Hello World Comprehensive Test Suite
// Production-grade testing following modern Aiken patterns

use hello_world/types.{HelloWorldDatum, HelloWorldRedeemer}
use hello_world/utils.{
  create_hello_datum, create_hello_redeemer, expected_message,
  validate_datum_params, validate_redeemer_params,
}

// === CORE FUNCTIONALITY TESTS ===

test correct_message_validation() {
  let message = expected_message()
  validate_redeemer_params(message)
}

test create_valid_datum() {
  let owner = "owner_pkh_123"
  let datum = create_hello_datum(owner)
  datum.owner == owner
}

test create_valid_redeemer() {
  let message = expected_message()
  let redeemer = create_hello_redeemer(message)
  redeemer.message == message
}

test datum_validation_succeeds() {
  let owner = "valid_owner_hash"
  validate_datum_params(owner)
}

test redeemer_validation_succeeds() {
  let message = expected_message()
  validate_redeemer_params(message)
}

// === SECURITY TESTS ===

test empty_owner_fails() {
  let empty_owner = ""
  !validate_datum_params(empty_owner)
}

test wrong_message_fails() {
  let wrong_message = "hello, world!"
  // Wrong case
  !validate_redeemer_params(wrong_message)
}

test empty_message_fails() {
  let empty_message = ""
  !validate_redeemer_params(empty_message)
}

test case_sensitive_message_fails() {
  let wrong_case = "HELLO, WORLD!"
  !validate_redeemer_params(wrong_case)
}

test similar_message_fails() {
  let similar = "Hello, World"
  // Missing exclamation
  !validate_redeemer_params(similar)
}

// === EDGE CASES ===

test whitespace_differences_fail() {
  let extra_spaces = " Hello, World! "
  !validate_redeemer_params(extra_spaces)
}

test unicode_differences_fail() {
  let unicode_msg = "Hello, World！"
  // Different exclamation mark
  !validate_redeemer_params(unicode_msg)
}

test long_owner_hash_works() {
  let long_owner =
    #"a1b2c3d4e5f6789012345678901234567890123456789012345678901234567890"
  validate_datum_params(long_owner)
}

// === INTEGRATION TESTS ===

test full_valid_flow() {
  let owner = "test_owner_hash"
  let message = expected_message()
  let datum = create_hello_datum(owner)
  let redeemer = create_hello_redeemer(message)
  and {
    validate_datum_params(datum.owner),
    validate_redeemer_params(redeemer.message),
    datum.owner == owner,
    redeemer.message == message,
  }
}

test full_invalid_flow() {
  let owner = ""
  // Invalid
  let message = "wrong message"
  // Invalid
  let datum = create_hello_datum(owner)
  let redeemer = create_hello_redeemer(message)
  or {
    !validate_datum_params(datum.owner),
    !validate_redeemer_params(redeemer.message),
  }
}

// === PERFORMANCE TESTS ===

test message_comparison_performance() {
  let message = expected_message()
  let expected = "Hello, World!"
  // This should be very fast
  message == expected
}
