// Security Tests for Secure Escrow Contract
// Tests that verify all critical vulnerabilities have been fixed

use aiken/transaction.{ScriptContext, Transaction, Input, Output, OutputReference}
use aiken/transaction/credential.{PubKeyHash}
use aiken/time.{Interval, Bound, Finite, Infinite}
use aiken/transaction/value.{Value}
use escrow/helpers.{
  EscrowDatum, EscrowAction, EscrowState, TaggedEscrowDatum,
  Active, Complete, Cancel, create_escrow_datum, create_tagged_datum
}

// Mock data for testing
const buyer_pkh: PubKeyHash = #"62757965725f6b65795f686173685f31323334353637383930"
const seller_pkh: PubKeyHash = #"73656c6c65725f6b65795f686173685f30393837363534333231"
const attacker_pkh: PubKeyHash = #"61747461636b65725f6b65795f686173685f31313131313131313131"
const escrow_amount: Int = 10_000_000  // 10 ADA
const deadline: Int = 1000
const nonce: Int = 1

fn create_mock_datum() -> EscrowDatum {
  create_escrow_datum(buyer_pkh, seller_pkh, escrow_amount, deadline, nonce)
}

fn create_mock_tagged_datum(
  original_datum: EscrowDatum,
  input_ref: OutputReference
) -> TaggedEscrowDatum {
  create_tagged_datum(original_datum, input_ref)
}

fn create_seller_payment_output(amount: Int) -> Output {
  Output {
    address: seller_pkh,
    value: Value { lovelace: amount, ..Value::default() },
    datum: None,
  }
}

fn create_buyer_payment_output(amount: Int) -> Output {
  Output {
    address: buyer_pkh,
    value: Value { lovelace: amount, ..Value::default() },
    datum: None,
  }
}

fn create_tagged_output(
  tagged_datum: TaggedEscrowDatum,
  amount: Int
) -> Output {
  Output {
    address: seller_pkh, // Script address would be used in real implementation
    value: Value { lovelace: amount, ..Value::default() },
    datum: InlineDatum(tagged_datum),
  }
}

fn before_deadline_interval() -> Interval {
  Interval {
    lower_bound: Finite(500),
    upper_bound: Finite(999),
  }
}

fn after_deadline_interval() -> Interval {
  Interval {
    lower_bound: Finite(1001),
    upper_bound: Finite(2000),
  }
}

// Test 1: Successful completion by buyer
test successful_completion() {
  let datum = create_mock_datum()
  let redeemer = Complete
  let input_ref = OutputReference { id: #"tx_hash", index: 0 }
  
  // Create tagged output with updated state
  let updated_datum = EscrowDatum {
    buyer: datum.buyer,
    seller: datum.seller,
    state: Complete,
    deadline: datum.deadline,
    amount: datum.amount,
    nonce: datum.nonce + 1,
    metadata: datum.metadata,
  }
  let tagged_datum = create_mock_tagged_datum(updated_datum, input_ref)
  
  let ctx = ScriptContext {
    transaction: Transaction {
      extra_signatories: [buyer_pkh],           // ✅ Buyer signed
      validity_range: before_deadline_interval(),  // ✅ Before deadline
      outputs: [
        create_seller_payment_output(escrow_amount),  // ✅ Payment to seller
        create_tagged_output(tagged_datum, 0),        // ✅ Tagged output
      ],
      ..Transaction::default()
    },
    purpose: Spending(input_ref)
  }
  
  escrow_contract.spend(datum, redeemer, input_ref, ctx)
}

// Test 2: Prevent completion without buyer signature (SECURITY)
test completion_requires_buyer_signature() fail {
  let datum = create_mock_datum()
  let redeemer = Complete
  let input_ref = OutputReference { id: #"tx_hash", index: 0 }
  
  let updated_datum = EscrowDatum {
    buyer: datum.buyer,
    seller: datum.seller,
    state: Complete,
    deadline: datum.deadline,
    amount: datum.amount,
    nonce: datum.nonce + 1,
    metadata: datum.metadata,
  }
  let tagged_datum = create_mock_tagged_datum(updated_datum, input_ref)
  
  let ctx = ScriptContext {
    transaction: Transaction {
      extra_signatories: [seller_pkh],          // ❌ Wrong signer!
      validity_range: before_deadline_interval(),
      outputs: [
        create_seller_payment_output(escrow_amount),
        create_tagged_output(tagged_datum, 0),
      ],
      ..Transaction::default()
    },
    purpose: Spending(input_ref)
  }
  
  // Should fail because buyer didn't sign
  escrow_contract.spend(datum, redeemer, input_ref, ctx)
}

// Test 3: Prevent completion after deadline (SECURITY)
test completion_fails_after_deadline() fail {
  let datum = create_mock_datum()
  let redeemer = Complete
  let input_ref = OutputReference { id: #"tx_hash", index: 0 }
  
  let updated_datum = EscrowDatum {
    buyer: datum.buyer,
    seller: datum.seller,
    state: Complete,
    deadline: datum.deadline,
    amount: datum.amount,
    nonce: datum.nonce + 1,
    metadata: datum.metadata,
  }
  let tagged_datum = create_mock_tagged_datum(updated_datum, input_ref)
  
  let ctx = ScriptContext {
    transaction: Transaction {
      extra_signatories: [buyer_pkh],           // ✅ Correct signer
      validity_range: after_deadline_interval(),  // ❌ After deadline!
      outputs: [
        create_seller_payment_output(escrow_amount),
        create_tagged_output(tagged_datum, 0),
      ],
      ..Transaction::default()
    },
    purpose: Spending(input_ref)
  }
  
  // Should fail because deadline passed
  escrow_contract.spend(datum, redeemer, input_ref, ctx)
}

// Test 4: Prevent payment theft (SECURITY)
test completion_requires_seller_payment() fail {
  let datum = create_mock_datum()
  let redeemer = Complete
  let input_ref = OutputReference { id: "tx_hash", index: 0 }
  
  let updated_datum = EscrowDatum {
    buyer: datum.buyer,
    seller: datum.seller,
    state: Complete,
    deadline: datum.deadline,
    amount: datum.amount,
    nonce: datum.nonce + 1,
    metadata: datum.metadata,
  }
  let tagged_datum = create_mock_tagged_datum(updated_datum, input_ref)
  
  let ctx = ScriptContext {
    transaction: Transaction {
      extra_signatories: [buyer_pkh],           // ✅ Correct signer
      validity_range: before_deadline_interval(),  // ✅ Correct time
      outputs: [
        Output {                              // ❌ Payment to attacker!
          address: attacker_pkh,
          value: Value { lovelace: escrow_amount, ..Value::default() },
          datum: None,
        },
        create_tagged_output(tagged_datum, 0),
      ],
      ..Transaction::default()
    },
    purpose: Spending(input_ref)
  }
  
  // Should fail because seller wasn't paid
  escrow_contract.spend(datum, redeemer, input_ref, ctx)
}

// Test 5: Successful cancellation by buyer
test successful_buyer_cancellation() {
  let datum = create_mock_datum()
  let redeemer = Cancel { canceller_is_buyer: True }
  let input_ref = OutputReference { id: #"tx_hash", index: 0 }
  
  let updated_datum = EscrowDatum {
    buyer: datum.buyer,
    seller: datum.seller,
    state: Cancel,
    deadline: datum.deadline,
    amount: datum.amount,
    nonce: datum.nonce + 1,
    metadata: datum.metadata,
  }
  let tagged_datum = create_mock_tagged_datum(updated_datum, input_ref)
  
  let ctx = ScriptContext {
    transaction: Transaction {
      extra_signatories: [buyer_pkh],           // ✅ Buyer signed
      validity_range: before_deadline_interval(),  // ✅ Before deadline
      outputs: [
        create_buyer_payment_output(escrow_amount),  // ✅ Refund to buyer
        create_tagged_output(tagged_datum, 0),
      ],
      ..Transaction::default()
    },
    purpose: Spending(input_ref)
  }
  
  escrow_contract.spend(datum, redeemer, input_ref, ctx)
}

// Test 6: Successful refund after deadline
test successful_seller_refund() {
  let datum = create_mock_datum()
  let redeemer = Refund
  let input_ref = OutputReference { id: #"tx_hash", index: 0 }
  
  let updated_datum = EscrowDatum {
    buyer: datum.buyer,
    seller: datum.seller,
    state: Cancel,
    deadline: datum.deadline,
    amount: datum.amount,
    nonce: datum.nonce + 1,
    metadata: datum.metadata,
  }
  let tagged_datum = create_mock_tagged_datum(updated_datum, input_ref)
  
  let ctx = ScriptContext {
    transaction: Transaction {
      extra_signatories: [seller_pkh],          // ✅ Seller signed
      validity_range: after_deadline_interval(),  // ✅ After deadline
      outputs: [
        create_buyer_payment_output(escrow_amount),  // ✅ Refund to buyer
        create_tagged_output(tagged_datum, 0),
      ],
      ..Transaction::default()
    },
    purpose: Spending(input_ref)
  }
  
  escrow_contract.spend(datum, redeemer, input_ref, ctx)
}

// Test 7: Prevent self-dealing (SECURITY)
test prevent_self_dealing() fail {
  let bad_datum = EscrowDatum {
    buyer: buyer_pkh,
    seller: buyer_pkh,                         // ❌ Same as buyer!
    state: Active,
    deadline: deadline,
    amount: escrow_amount,
    nonce: nonce,
    metadata: None,
  }
  
  let redeemer = Complete
  let input_ref = OutputReference { id: #"tx_hash", index: 0 }
  
  let ctx = ScriptContext {
    transaction: Transaction {
      extra_signatories: [buyer_pkh],
      validity_range: before_deadline_interval(),
      outputs: [
        create_seller_payment_output(escrow_amount),
        create_tagged_output(create_mock_tagged_datum(bad_datum, input_ref), 0),
      ],
      ..Transaction::default()
    },
    purpose: Spending(input_ref)
  }
  
  // Should fail because buyer == seller
  escrow_contract.spend(bad_datum, redeemer, input_ref, ctx)
}

// Test 8: Prevent zero/negative amounts (SECURITY)
test prevent_zero_amount() fail {
  let bad_datum = EscrowDatum {
    buyer: buyer_pkh,
    seller: seller_pkh,
    state: Active,
    deadline: deadline,
    amount: 0,                                // ❌ Zero amount!
    nonce: nonce,
    metadata: None,
  }
  
  let redeemer = Complete
  let input_ref = OutputReference { id: #"tx_hash", index: 0 }
  
  let ctx = ScriptContext {
    transaction: Transaction {
      extra_signatories: [buyer_pkh],
      validity_range: before_deadline_interval(),
      outputs: [
        create_seller_payment_output(0),
        create_tagged_output(create_mock_tagged_datum(bad_datum, input_ref), 0),
      ],
      ..Transaction::default()
    },
    purpose: Spending(input_ref)
  }
  
  // Should fail because amount is zero
  escrow_contract.spend(bad_datum, redeemer, input_ref, ctx)
}

// Test 9: Prevent double satisfaction attack (CRITICAL SECURITY)
test prevent_double_satisfaction() fail {
  let datum = create_mock_datum()
  let redeemer = Complete
  let input_ref = OutputReference { id: #"tx_hash", index: 0 }
  
  let updated_datum = EscrowDatum {
    buyer: datum.buyer,
    seller: datum.seller,
    state: Complete,
    deadline: datum.deadline,
    amount: datum.amount,
    nonce: datum.nonce + 1,
    metadata: datum.metadata,
  }
  let tagged_datum = create_mock_tagged_datum(updated_datum, input_ref)
  
  let ctx = ScriptContext {
    transaction: Transaction {
      extra_signatories: [buyer_pkh],
      validity_range: before_deadline_interval(),
      outputs: [
        create_seller_payment_output(escrow_amount),
        // ❌ Missing tagged output - should fail
      ],
      ..Transaction::default()
    },
    purpose: Spending(input_ref)
  }
  
  // Should fail because no tagged output exists
  escrow_contract.spend(datum, redeemer, input_ref, ctx)
}

// Test 10: Prevent replay attacks (CRITICAL SECURITY)
test prevent_replay_attack() fail {
  let datum = create_mock_datum()
  let redeemer = Complete
  let input_ref = OutputReference { id: #"tx_hash", index: 0 }
  
  let updated_datum = EscrowDatum {
    buyer: datum.buyer,
    seller: datum.seller,
    state: Complete,
    deadline: datum.deadline,
    amount: datum.amount,
    nonce: datum.nonce,  // ❌ Same nonce - should increment!
    metadata: datum.metadata,
  }
  let tagged_datum = create_mock_tagged_datum(updated_datum, input_ref)
  
  let ctx = ScriptContext {
    transaction: Transaction {
      extra_signatories: [buyer_pkh],
      validity_range: before_deadline_interval(),
      outputs: [
        create_seller_payment_output(escrow_amount),
        create_tagged_output(tagged_datum, 0),
      ],
      ..Transaction::default()
    },
    purpose: Spending(input_ref)
  }
  
  // Should fail because nonce wasn't incremented
  escrow_contract.spend(datum, redeemer, input_ref, ctx)
}

// Test 11: Prevent modification of completed escrow
test prevent_modify_completed_escrow() fail {
  let completed_datum = EscrowDatum {
    buyer: buyer_pkh,
    seller: seller_pkh,
    state: Complete,                           // ❌ Already completed!
    deadline: deadline,
    amount: escrow_amount,
    nonce: nonce,
    metadata: None,
  }
  
  let redeemer = Cancel { canceller_is_buyer: True }
  let input_ref = OutputReference { id: #"tx_hash", index: 0 }
  
  let ctx = ScriptContext {
    transaction: Transaction {
      extra_signatories: [buyer_pkh],
      validity_range: before_deadline_interval(),
      outputs: [
        create_buyer_payment_output(escrow_amount),
        create_tagged_output(create_mock_tagged_datum(completed_datum, input_ref), 0),
      ],
      ..Transaction::default()
    },
    purpose: Spending(input_ref)
  }
  
  // Should fail because escrow is already completed
  escrow_contract.spend(completed_datum, redeemer, input_ref, ctx)
}

// Test 12: Validate proper state transitions
test validate_state_transitions() {
  let datum = create_mock_datum()
  
  // Test valid transitions
  assert validate_state_transition(Active, Complete) == Valid
  assert validate_state_transition(Active, Cancel { canceller_is_buyer: True }) == Valid
  assert validate_state_transition(Active, Refund) == Valid
  
  // Test invalid transitions
  assert validate_state_transition(Complete, Complete) == Invalid("Cannot modify completed escrow")
  assert validate_state_transition(Cancel, Complete) == Invalid("Cannot modify cancelled escrow")
}

// Test 13: Validate escrow parameters
test validate_escrow_parameters() {
  let config = default_config()
  
  // Test valid parameters
  let valid_datum = create_mock_datum()
  assert validate_escrow_datum(valid_datum, config) == Valid
  
  // Test invalid parameters
  let invalid_amount_datum = EscrowDatum {
    buyer: buyer_pkh,
    seller: seller_pkh,
    state: Active,
    deadline: deadline,
    amount: 500_000,  // Below minimum
    nonce: nonce,
    metadata: None,
  }
  assert validate_escrow_datum(invalid_amount_datum, config) == Invalid("Escrow amount below minimum")
}

// Test 14: Benchmark critical operations
test bench completion_validation() {
  let datum = create_mock_datum()
  let redeemer = Complete
  let input_ref = OutputReference { id: #"tx_hash", index: 0 }
  
  let updated_datum = EscrowDatum {
    buyer: datum.buyer,
    seller: datum.seller,
    state: Complete,
    deadline: datum.deadline,
    amount: datum.amount,
    nonce: datum.nonce + 1,
    metadata: datum.metadata,
  }
  let tagged_datum = create_mock_tagged_datum(updated_datum, input_ref)
  
  let ctx = ScriptContext {
    transaction: Transaction {
      extra_signatories: [buyer_pkh],
      validity_range: before_deadline_interval(),
      outputs: [
        create_seller_payment_output(escrow_amount),
        create_tagged_output(tagged_datum, 0),
      ],
      ..Transaction::default()
    },
    purpose: Spending(input_ref)
  }
  
  // Benchmark the completion validation
  escrow_contract.spend(datum, redeemer, input_ref, ctx)
}
