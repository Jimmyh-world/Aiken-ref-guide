// Escrow Contract Tests
// Comprehensive test suite for the escrow contract state machine

use escrow/helpers.{
  EscrowDatum,
  EscrowAction,
  EscrowState,
  EscrowConfig,
  ValidationResult,
  validate_escrow_datum,
  validate_state_transition,
  validate_deadline,
  validate_after_deadline,
  validate_buyer_signature,
  validate_canceller_signature,
  validate_seller_signature,
  validate_output_amount,
  validate_output_recipient,
  update_escrow_state,
  is_final_state,
  default_config,
  Active,
  Complete,
  Cancel,
  CompleteEscrow,
  CancelEscrow,
  Refund,
  Valid,
  Invalid,
}

// Mock escrow datum for testing
fn create_mock_datum(
  state: EscrowState,
  amount: Int,
) -> EscrowDatum {
  EscrowDatum {
    buyer: "buyer_key_hash", // BUYER_KEY_HASH
    seller: "seller_key_hash", // SELLER_KEY_HASH
    state: state,
    deadline: 1000, // DEADLINE
    amount: amount,
    metadata: None
  }
}

// Test escrow datum validation
test valid_escrow_datum() {
  let datum = create_mock_datum(Active, 10_000_000) // ESCROW_AMOUNT
  let result = validate_escrow_datum(datum, default_config())
  result == Valid
}

test invalid_escrow_datum_amount_too_low() {
  let datum = create_mock_datum(Active, 100_000) // Below minimum
  let result = validate_escrow_datum(datum, default_config())
  result == Invalid("Escrow amount below minimum")
}

test invalid_escrow_datum_amount_too_high() {
  let datum = create_mock_datum(Active, 2_000_000_000_000) // Above maximum
  let result = validate_escrow_datum(datum, default_config())
  result == Invalid("Escrow amount above maximum")
}

test invalid_escrow_datum_same_parties() {
  let datum = EscrowDatum {
    buyer: "same_key_hash",
    seller: "same_key_hash", // Same as buyer
    state: Active,
    deadline: 1000,
    amount: 10_000_000,
    metadata: None
  }
  let result = validate_escrow_datum(datum, default_config())
  result == Invalid("Buyer and seller cannot be the same")
}

test invalid_escrow_datum_negative_deadline() {
  let datum = EscrowDatum {
    buyer: "buyer_key_hash",
    seller: "seller_key_hash",
    state: Active,
    deadline: -100, // Negative deadline
    amount: 10_000_000,
    metadata: None
  }
  let result = validate_escrow_datum(datum, default_config())
  result == Invalid("Deadline must be positive")
}

// Test state transition validation
test valid_state_transition_active_to_complete() {
  let action = CompleteEscrow { buyer_signature: "valid_signature" } // VALID_SIGNATURE
  let result = validate_state_transition(Active, action)
  result == Valid
}

test valid_state_transition_active_to_cancel() {
  let action = CancelEscrow { 
    canceller_signature: "valid_signature", // VALID_SIGNATURE
    is_buyer: True
  }
  let result = validate_state_transition(Active, action)
  result == Valid
}

test valid_state_transition_active_to_refund() {
  let action = Refund { seller_signature: "valid_signature" } // VALID_SIGNATURE
  let result = validate_state_transition(Active, action)
  result == Valid
}

test invalid_state_transition_complete_to_complete() {
  let action = CompleteEscrow { buyer_signature: "valid_signature" } // VALID_SIGNATURE
  let result = validate_state_transition(Complete, action)
  result == Invalid("Cannot modify completed escrow")
}

test invalid_state_transition_cancel_to_complete() {
  let action = CompleteEscrow { buyer_signature: "valid_signature" } // VALID_SIGNATURE
  let result = validate_state_transition(Cancel, action)
  result == Invalid("Cannot modify cancelled escrow")
}

// Test deadline validation
test valid_deadline_before_deadline() {
  let result = validate_deadline(1000) // DEADLINE
  result == Valid
}

test valid_after_deadline() {
  let result = validate_after_deadline(1000) // DEADLINE
  result == Valid
}

// Test signature validation
test valid_buyer_signature() {
  let action = CompleteEscrow { buyer_signature: "valid_signature" } // VALID_SIGNATURE
  let datum = create_mock_datum(Active, 10_000_000) // ESCROW_AMOUNT
  let result = validate_buyer_signature(action, datum)
  result == Valid
}

test invalid_buyer_signature_empty() {
  let action = CompleteEscrow { buyer_signature: "" } // INVALID_SIGNATURE
  let datum = create_mock_datum(Active, 10_000_000) // ESCROW_AMOUNT
  let result = validate_buyer_signature(action, datum)
  result == Invalid("Invalid buyer signature")
}

test invalid_buyer_signature_wrong_action() {
  let action = CancelEscrow { 
    canceller_signature: "valid_signature", // VALID_SIGNATURE
    is_buyer: True
  }
  let datum = create_mock_datum(Active, 10_000_000) // ESCROW_AMOUNT
  let result = validate_buyer_signature(action, datum)
  result == Invalid("Action is not a completion")
}

// Test output validation
test valid_output_amount() {
  let result = validate_output_amount(10_000_000) // ESCROW_AMOUNT
  result == Valid
}

test valid_output_recipient() {
  let result = validate_output_recipient("seller_key_hash") // SELLER_KEY_HASH
  result == Valid
}

// Test state update functions
// test update_escrow_state() {
//   let original_datum = create_mock_datum(Active, 10_000_000) // ESCROW_AMOUNT
//   let updated_datum = update_escrow_state(original_datum, Complete)
//   
//   updated_datum.state == Complete &&
//   updated_datum.buyer == original_datum.buyer &&
//   updated_datum.seller == original_datum.seller &&
//   updated_datum.amount == original_datum.amount
// }

test is_final_state_active() {
  is_final_state(Active) == False
}

test is_final_state_complete() {
  is_final_state(Complete) == True
}

test is_final_state_cancel() {
  is_final_state(Cancel) == True
}

// Test edge cases
test edge_case_zero_amount() {
  let datum = create_mock_datum(Active, 0)
  let result = validate_escrow_datum(datum, default_config())
  result == Invalid("Escrow amount below minimum")
}

test edge_case_maximum_amount() {
  let datum = create_mock_datum(Active, default_config().max_amount)
  let result = validate_escrow_datum(datum, default_config())
  result == Valid
}

test edge_case_minimum_amount() {
  let datum = create_mock_datum(Active, default_config().min_amount)
  let result = validate_escrow_datum(datum, default_config())
  result == Valid
}

// Test cancellation by buyer vs seller
test valid_cancellation_by_buyer() {
  let action = CancelEscrow { 
    canceller_signature: "valid_signature", // VALID_SIGNATURE
    is_buyer: True
  }
  let datum = create_mock_datum(Active, 10_000_000) // ESCROW_AMOUNT
  let result = validate_canceller_signature(action, datum)
  result == Valid
}

test valid_cancellation_by_seller() {
  let action = CancelEscrow { 
    canceller_signature: "valid_signature", // VALID_SIGNATURE
    is_buyer: False
  }
  let datum = create_mock_datum(Active, 10_000_000) // ESCROW_AMOUNT
  let result = validate_canceller_signature(action, datum)
  result == Valid
}

// Test refund validation
test valid_refund_signature() {
  let action = Refund { seller_signature: "valid_signature" } // VALID_SIGNATURE
  let datum = create_mock_datum(Active, 10_000_000) // ESCROW_AMOUNT
  let result = validate_seller_signature(action, datum)
  result == Valid
}

test invalid_refund_signature_empty() {
  let action = Refund { seller_signature: "" } // INVALID_SIGNATURE
  let datum = create_mock_datum(Active, 10_000_000) // ESCROW_AMOUNT
  let result = validate_seller_signature(action, datum)
  result == Invalid("Invalid seller signature")
}

// Performance benchmark tests
test bench_validate_escrow_datum_performance() {
  let datum = create_mock_datum(Active, 10_000_000) // ESCROW_AMOUNT
  let _ = validate_escrow_datum(datum, default_config())
  True
}

test bench_validate_state_transition_performance() {
  let action = CompleteEscrow { buyer_signature: "valid_signature" } // VALID_SIGNATURE
  let _ = validate_state_transition(Active, action)
  True
}

test bench_validate_deadline_performance() {
  let _ = validate_deadline(1000) // DEADLINE
  True
}

test bench_signature_validation_performance() {
  let action = CompleteEscrow { buyer_signature: "valid_signature" } // VALID_SIGNATURE
  let datum = create_mock_datum(Active, 10_000_000) // ESCROW_AMOUNT
  let _ = validate_buyer_signature(action, datum)
  True
}
