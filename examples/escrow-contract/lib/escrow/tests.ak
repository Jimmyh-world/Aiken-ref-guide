// Secure Escrow Contract Tests
// Comprehensive test suite for the escrow contract

use escrow/helpers.{
  Active, Cancel, CancelEscrow, Complete, CompleteEscrow, EscrowDatum,
  RefundEscrow, create_escrow_datum, default_config, is_final_state,
  validate_escrow_datum, validate_escrow_params, validate_state_transition,
}

// Test successful completion
test successful_completion() {
  let datum =
    EscrowDatum {
      buyer: #"62757965725f6b65795f68617368",
      seller: #"73656c6c65725f6b65795f68617368",
      state: Active,
      deadline: 1000,
      amount: 10_000_000,
      nonce: 1,
      metadata: None,
    }
  // Test datum validation
  validate_escrow_datum(datum, default_config())
}

// Test prevents self-dealing
test prevent_self_dealing() fail {
  let bad_datum =
    EscrowDatum {
      buyer: #"73616d655f6b65795f68617368",
      seller: #"73616d655f6b65795f68617368",
      // Same as buyer
      state: Active,
      deadline: 1000,
      amount: 10_000_000,
      nonce: 1,
      metadata: None,
    }
  validate_escrow_datum(bad_datum, default_config())
}

// Test prevents zero amount
test prevent_zero_amount() fail {
  let bad_datum =
    EscrowDatum {
      buyer: #"62757965725f6b65795f68617368",
      seller: #"73656c6c65725f6b65795f68617368",
      state: Active,
      deadline: 1000,
      amount: 0,
      // Invalid amount
      nonce: 1,
      metadata: None,
    }
  validate_escrow_datum(bad_datum, default_config())
}

// Test prevents negative deadline
test prevent_negative_deadline() fail {
  let bad_datum =
    EscrowDatum {
      buyer: #"62757965725f6b65795f68617368",
      seller: #"73656c6c65725f6b65795f68617368",
      state: Active,
      deadline: -100,
      // Invalid deadline
      amount: 10_000_000,
      nonce: 1,
      metadata: None,
    }
  validate_escrow_datum(bad_datum, default_config())
}

// Test prevents zero nonce
test prevent_zero_nonce() fail {
  let bad_datum =
    EscrowDatum {
      buyer: #"62757965725f6b65795f68617368",
      seller: #"73656c6c65725f6b65795f68617368",
      state: Active,
      deadline: 1000,
      amount: 10_000_000,
      nonce: 0,
      // Invalid nonce
      metadata: None,
    }
  validate_escrow_datum(bad_datum, default_config())
}

// Test state transitions
test valid_state_transitions() {
  let active_state = Active
  let complete_state = Complete
  let cancel_state = Cancel
  and {
    // Active state allows all actions
    validate_state_transition(active_state, CompleteEscrow),
    validate_state_transition(
      active_state,
      CancelEscrow { canceller_is_buyer: True },
    ),
    validate_state_transition(
      active_state,
      CancelEscrow { canceller_is_buyer: False },
    ),
    validate_state_transition(active_state, RefundEscrow),
    // Final states don't allow any actions
    !validate_state_transition(complete_state, CompleteEscrow),
    !validate_state_transition(
      complete_state,
      CancelEscrow { canceller_is_buyer: True },
    ),
    !validate_state_transition(complete_state, RefundEscrow),
    !validate_state_transition(cancel_state, CompleteEscrow),
    !validate_state_transition(
      cancel_state,
      CancelEscrow { canceller_is_buyer: True },
    ),
    !validate_state_transition(cancel_state, RefundEscrow),
  }
}

// Test final state detection
test final_state_detection() {
  and {
    !is_final_state(Active),
    is_final_state(Complete),
    is_final_state(Cancel),
  }
}

// Test datum creation
test create_valid_datum() {
  let buyer = #"62757965725f6b65795f68617368"
  let seller = #"73656c6c65725f6b65795f68617368"
  let amount = 10_000_000
  let deadline = 1000
  let nonce = 1
  let datum = create_escrow_datum(buyer, seller, amount, deadline, nonce)
  and {
    datum.buyer == buyer,
    datum.seller == seller,
    datum.state == Active,
    datum.amount == amount,
    datum.deadline == deadline,
    datum.nonce == nonce,
    datum.metadata == None,
  }
}

// Test parameter validation
test validate_parameters() {
  let buyer = #"62757965725f6b65795f68617368"
  let seller = #"73656c6c65725f6b65795f68617368"
  let amount = 10_000_000
  let deadline = 1000
  let nonce = 1
  validate_escrow_params(buyer, seller, amount, deadline, nonce)
}

// Test parameter validation fails for invalid inputs
test validate_parameters_fails_for_invalid() {
  let buyer = #"62757965725f6b65795f68617368"
  let seller = #"73656c6c65725f6b65795f68617368"
  and {
    // Self-dealing
    !validate_escrow_params(buyer, buyer, 10_000_000, 1000, 1),
    // Too small amount
    !validate_escrow_params(buyer, seller, 500_000, 1000, 1),
    // Invalid deadline
    !validate_escrow_params(buyer, seller, 10_000_000, 0, 1),
    // Invalid nonce
    !validate_escrow_params(buyer, seller, 10_000_000, 1000, 0),
  }
}

// Test minimum amount validation
test minimum_amount_validation() {
  let buyer = #"62757965725f6b65795f68617368"
  let seller = #"73656c6c65725f6b65795f68617368"
  let deadline = 1000
  let nonce = 1
  and {
    // Exactly minimum amount should pass
    validate_escrow_params(buyer, seller, 1_000_000, deadline, nonce),
    // Above minimum should pass
    validate_escrow_params(buyer, seller, 2_000_000, deadline, nonce),
    // Below minimum should fail
    !validate_escrow_params(buyer, seller, 999_999, deadline, nonce),
  }
}
