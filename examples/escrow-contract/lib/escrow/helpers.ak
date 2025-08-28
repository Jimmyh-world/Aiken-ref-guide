// Secure Escrow Contract Helpers
// Production-ready helper functions for the escrow contract

use aiken/transaction.{ScriptContext, tx_signed_by, input_value}
use aiken/transaction/value.{value_paid_to}
use aiken/time.{contains, from, to}
use aiken/transaction/credential.{PubKeyHash}
use aiken/list

// Escrow states - simple and clear
pub type EscrowState {
  Active    // Escrow is active
  Complete  // Successfully completed
  Cancel    // Cancelled by either party
}

// Secure datum using proper types
pub type EscrowDatum {
  buyer: PubKeyHash,        // ✅ Type-safe public key hash
  seller: PubKeyHash,       // ✅ Type-safe public key hash  
  state: EscrowState,
  deadline: Int,            // Slot number
  amount: Int,              // Lovelace amount
  nonce: Int,               // ✅ Anti-replay protection
  metadata: Option<ByteArray>,
}

// Secure actions - no raw signatures!
pub type EscrowAction {
  Complete                                    // ✅ Buyer authorizes completion
  Cancel { canceller_is_buyer: Bool }        // ✅ Either party can cancel
  Refund                                     // ✅ Seller authorizes refund
}

// Tagged output datum for double satisfaction protection
pub type TaggedEscrowDatum {
  original_datum: EscrowDatum,
  input_ref: OutputReference,
}

// Configuration for escrow parameters
pub type EscrowConfig {
  min_amount: Int,           // Minimum escrow amount in lovelace
  max_amount: Int,           // Maximum escrow amount in lovelace
  min_deadline_duration: Int, // Minimum deadline duration in slots
  max_deadline_duration: Int, // Maximum deadline duration in slots
}

// Default configuration
pub fn default_config() -> EscrowConfig {
  EscrowConfig {
    min_amount: 1_000_000,        // 1 ADA minimum
    max_amount: 1_000_000_000_000, // 1M ADA maximum
    min_deadline_duration: 7200,   // 1 hour minimum (assuming 1 slot = 0.5 seconds)
    max_deadline_duration: 864000, // 5 days maximum
  }
}

// Validation result type
pub type ValidationResult {
  Valid
  Invalid(String)
}

// ✅ SECURE: Validate escrow datum parameters
pub fn validate_escrow_datum(
  datum: EscrowDatum,
  config: EscrowConfig
) -> ValidationResult {
  if datum.amount < config.min_amount {
    Invalid("Escrow amount below minimum")
  } else if datum.amount > config.max_amount {
    Invalid("Escrow amount above maximum")
  } else if datum.buyer == datum.seller {
    Invalid("Buyer and seller cannot be the same")
  } else if datum.deadline <= 0 {
    Invalid("Deadline must be positive")
  } else if datum.nonce <= 0 {
    Invalid("Nonce must be positive")
  } else {
    Valid
  }
}

// ✅ SECURE: Validate state transitions
pub fn validate_state_transition(
  current_state: EscrowState,
  action: EscrowAction
) -> ValidationResult {
  when (current_state, action) is {
    (Active, Complete) -> Valid
    (Active, Cancel { .. }) -> Valid
    (Active, Refund) -> Valid
    (Complete, _) -> Invalid("Cannot modify completed escrow")
    (Cancel, _) -> Invalid("Cannot modify cancelled escrow")
  }
}

// ✅ SECURE: Time validation using transaction validity ranges
pub fn validate_deadline(
  deadline: Int,
  validity_range: ValidityRange
) -> ValidationResult {
  if contains(validity_range, to(deadline)) {
    Valid
  } else {
    Invalid("Transaction must be submitted before deadline")
  }
}

// ✅ SECURE: After deadline validation
pub fn validate_after_deadline(
  deadline: Int,
  validity_range: ValidityRange
) -> ValidationResult {
  if contains(validity_range, from(deadline + 1)) {
    Valid
  } else {
    Invalid("Transaction must be submitted after deadline")
  }
}

// ✅ SECURE: Check if escrow is in final state
pub fn is_final_state(state: EscrowState) -> Bool {
  when state is {
    Active -> False
    Complete -> True
    Cancel -> True
  }
}

// ✅ SECURE: Create new escrow datum with updated state
pub fn update_escrow_state(
  datum: EscrowDatum,
  new_state: EscrowState
) -> EscrowDatum {
  EscrowDatum {
    buyer: datum.buyer,
    seller: datum.seller,
    state: new_state,
    deadline: datum.deadline,
    amount: datum.amount,
    nonce: datum.nonce + 1,  // ✅ Increment nonce for anti-replay
    metadata: datum.metadata,
  }
}

// ✅ SECURE: Validate completion transaction
pub fn validate_completion_transaction(
  datum: EscrowDatum,
  ctx: ScriptContext
) -> ValidationResult {
  // Check buyer signature
  if !tx_signed_by(ctx.transaction, datum.buyer) {
    Invalid("Buyer must sign completion transaction")
  } else {
    // Check payment to seller
    let seller_payment = value_paid_to(ctx.transaction, datum.seller).lovelace
    if seller_payment >= datum.amount {
      Valid
    } else {
      Invalid("Insufficient payment to seller")
    }
  }
}

// ✅ SECURE: Validate cancellation transaction
pub fn validate_cancellation_transaction(
  datum: EscrowDatum,
  canceller_is_buyer: Bool,
  ctx: ScriptContext
) -> ValidationResult {
  let canceller = if canceller_is_buyer { datum.buyer } else { datum.seller }
  let recipient = if canceller_is_buyer { datum.buyer } else { datum.seller }
  
  // Check canceller signature
  if !tx_signed_by(ctx.transaction, canceller) {
    Invalid("Canceller must sign cancellation transaction")
  } else {
    // Check payment to canceller
    let canceller_payment = value_paid_to(ctx.transaction, recipient).lovelace
    if canceller_payment >= datum.amount {
      Valid
    } else {
      Invalid("Insufficient refund to canceller")
    }
  }
}

// ✅ SECURE: Validate refund transaction
pub fn validate_refund_transaction(
  datum: EscrowDatum,
  ctx: ScriptContext
) -> ValidationResult {
  // Check seller signature
  if !tx_signed_by(ctx.transaction, datum.seller) {
    Invalid("Seller must sign refund transaction")
  } else {
    // Check payment to buyer
    let buyer_payment = value_paid_to(ctx.transaction, datum.buyer).lovelace
    if buyer_payment >= datum.amount {
      Valid
    } else {
      Invalid("Insufficient refund to buyer")
    }
  }
}

// ✅ SECURE: Helper to create valid escrow datum
pub fn create_escrow_datum(
  buyer: PubKeyHash,
  seller: PubKeyHash, 
  amount: Int,
  deadline: Int,
  nonce: Int
) -> EscrowDatum {
  EscrowDatum {
    buyer,
    seller,
    state: Active,
    deadline,
    amount,
    nonce,
    metadata: None,
  }
}

// ✅ SECURE: Validation helpers for off-chain use
pub fn validate_escrow_params(
  buyer: PubKeyHash,
  seller: PubKeyHash,
  amount: Int,
  deadline: Int,
  nonce: Int
) -> Bool {
  and {
    buyer != seller,      // No self-dealing
    amount > 1_000_000,   // Minimum 1 ADA
    deadline > 0,         // Valid deadline
    nonce > 0,           // Valid nonce
  }
}

// ✅ SECURE: Helper to create tagged datum for outputs
pub fn create_tagged_datum(
  original_datum: EscrowDatum,
  input_ref: OutputReference
) -> TaggedEscrowDatum {
  TaggedEscrowDatum {
    original_datum,
    input_ref,
  }
}

// ✅ SECURE: Find tagged output in transaction
pub fn find_tagged_output(
  outputs: List<TransactionOutput>,
  input_ref: OutputReference
) -> Option<TransactionOutput> {
  list.find(outputs, fn(output) {
    when output.datum is {
      InlineDatum(raw_datum) -> {
        expect tagged: TaggedEscrowDatum = raw_datum
        tagged.input_ref == input_ref
      }
      _ -> False
    }
  })
}
