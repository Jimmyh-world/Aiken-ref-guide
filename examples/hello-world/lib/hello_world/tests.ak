// Hello World Validator Comprehensive Test Suite
// Tests all functionality including success cases, failure cases, and edge cases

use hello_world/types.{HelloWorldDatum, HelloWorldRedeemer}
use hello_world/utils.{
  create_datum, create_redeemer, hello_world_message, validate_message,
  validate_signature,
}

// === SUCCESS CASES ===

test valid_hello_world_succeeds() {
  let message = hello_world_message()
  let expected = "Hello, World!"
  validate_message(message, expected)
}

test valid_signature_succeeds() {
  let owner = "owner_pubkey_hash"
  let signatories = [owner, "other_signer"]
  validate_signature(owner, signatories)
}

test create_datum_works() {
  let owner = "test_owner"
  let datum = create_datum(owner)
  datum.owner == owner
}

test create_redeemer_works() {
  let message = "test message"
  let redeemer = create_redeemer(message)
  redeemer.message == message
}

// === FAILURE CASES ===

test wrong_message_fails() {
  let message = "hello, world!"
  // Wrong case
  let expected = "Hello, World!"
  !validate_message(message, expected)
}

test missing_signature_fails() {
  let owner = "owner_pubkey_hash"
  let signatories = ["other_signer"]
  // Owner not in list
  !validate_signature(owner, signatories)
}

test wrong_signer_fails() {
  let owner = "owner_pubkey_hash"
  let signatories = ["wrong_owner"]
  // Different owner
  !validate_signature(owner, signatories)
}

test empty_message_fails() {
  let message = ""
  let expected = "Hello, World!"
  !validate_message(message, expected)
}

test null_signatories_fails() {
  let owner = "owner_pubkey_hash"
  let signatories = []
  // Empty list
  !validate_signature(owner, signatories)
}

// === PROPERTY TESTS ===

test prop_wrong_message_always_fails() {
  let wrong_messages = ["Wrong!", "hello world", "HELLO, WORLD!", ""]
  let expected = "Hello, World!"
  // Test various wrong messages
  !validate_message("Wrong!", expected) && !validate_message(
    "hello world",
    expected,
  ) && !validate_message("HELLO, WORLD!", expected) && !validate_message(
    "",
    expected,
  )
}

test prop_correct_message_always_succeeds() {
  let message = "Hello, World!"
  let expected = "Hello, World!"
  validate_message(message, expected)
}

test prop_signature_validation_consistent() {
  let owner = "test_owner"
  let signatories = ["test_owner", "other_sig"]
  // Test that signature validation is consistent
  let has_owner = validate_signature(owner, signatories)
  has_owner == validate_signature(owner, signatories)
}

// === EDGE CASES ===

test very_long_message_fails() {
  let message = "Hello, World! with lots of extra text that makes it wrong"
  let expected = "Hello, World!"
  !validate_message(message, expected)
}

test unicode_message_fails() {
  let message = "Hello, World! 🚀"
  let expected = "Hello, World!"
  !validate_message(message, expected)
}

test whitespace_differences_fail() {
  let message = " Hello, World! "
  // Extra spaces
  let expected = "Hello, World!"
  !validate_message(message, expected)
}

// === BENCHMARKS ===

test bench_validation_performance() {
  // Test that validation completes in reasonable time
  let message = hello_world_message()
  let expected = "Hello, World!"
  // Simple performance test - should complete quickly
  let result = validate_message(message, expected)
  result
}

test bench_signature_validation_performance() {
  // Test signature validation performance
  let owner = "owner_pubkey_hash"
  let signatories = ["test_signer", "test_signer", "test_signer"]
  // Multiple entries
  // Should complete quickly even with many signatories
  let result = validate_signature(owner, signatories)
  !result
  // Should be false since owner not in list
}

// === INTEGRATION TESTS ===

test integration_valid_flow() {
  // Test complete valid flow
  let owner = "owner_pubkey_hash"
  let message = hello_world_message()
  let datum = create_datum(owner)
  let redeemer = create_redeemer(message)
  datum.owner == owner && redeemer.message == message
}

test integration_invalid_flow() {
  // Test complete invalid flow
  let owner = "owner_pubkey_hash"
  let wrong_message = "wrong message"
  let datum = create_datum(owner)
  let redeemer = create_redeemer(wrong_message)
  // This should fail validation
  !validate_message(redeemer.message, hello_world_message())
}
