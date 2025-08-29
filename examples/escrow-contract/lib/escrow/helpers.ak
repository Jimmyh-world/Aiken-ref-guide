// Secure Escrow Contract Helpers
// Production-ready helper functions for the escrow contract

// Escrow states - simple and clear
pub type EscrowState {
  Active
  // Escrow is active
  Complete
  // Successfully completed
  Cancel
}

// Cancelled by either party

// Secure datum using proper types
pub type EscrowDatum {
  buyer: ByteArray,
  // Public key hash
  seller: ByteArray,
  // Public key hash  
  state: EscrowState,
  deadline: Int,
  // Slot number
  amount: Int,
  // Lovelace amount
  nonce: Int,
  // ✅ Anti-replay protection
  metadata: Option<ByteArray>,
}

// Secure actions - no raw signatures!
pub type EscrowAction {
  CompleteEscrow
  // ✅ Buyer authorizes completion
  CancelEscrow { canceller_is_buyer: Bool }
  // ✅ Either party can cancel
  RefundEscrow
}

// ✅ Seller authorizes refund

// Configuration for escrow parameters
pub type EscrowConfig {
  min_amount: Int,
  // Minimum escrow amount in lovelace
  max_amount: Int,
  // Maximum escrow amount in lovelace
  min_deadline_duration: Int,
  // Minimum deadline duration in slots
  max_deadline_duration: Int,
}

// Maximum deadline duration in slots

// Default configuration
pub fn default_config() -> EscrowConfig {
  EscrowConfig {
    min_amount: 1_000_000,
    // 1 ADA minimum
    max_amount: 1_000_000_000_000,
    // 1M ADA maximum
    min_deadline_duration: 7200,
    // 1 hour minimum (assuming 1 slot = 0.5 seconds)
    max_deadline_duration: 864000,
  }
  // 5 days maximum
}

// ✅ SECURE: Validate escrow datum parameters
pub fn validate_escrow_datum(
  datum: EscrowDatum,
  config: EscrowConfig,
) -> Bool {
  and {
    datum.amount >= config.min_amount,
    datum.amount <= config.max_amount,
    datum.buyer != datum.seller,
    datum.deadline > 0,
    datum.nonce > 0,
  }
}

// ✅ SECURE: Validate state transitions
pub fn validate_state_transition(
  current_state: EscrowState,
  action: EscrowAction,
) -> Bool {
  when (current_state, action) is {
    (Active, CompleteEscrow) -> True
    (Active, CancelEscrow { .. }) -> True
    (Active, RefundEscrow) -> True
    (Complete, _) -> False
    (Cancel, _) -> False
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
  new_state: EscrowState,
) -> EscrowDatum {
  EscrowDatum {
    buyer: datum.buyer,
    seller: datum.seller,
    state: new_state,
    deadline: datum.deadline,
    amount: datum.amount,
    nonce: datum.nonce + 1,
    // ✅ Increment nonce for anti-replay
    metadata: datum.metadata,
  }
}

// ✅ SECURE: Helper to create valid escrow datum
pub fn create_escrow_datum(
  buyer: ByteArray,
  seller: ByteArray,
  amount: Int,
  deadline: Int,
  nonce: Int,
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
  buyer: ByteArray,
  seller: ByteArray,
  amount: Int,
  deadline: Int,
  nonce: Int,
) -> Bool {
  and {
    buyer != seller,
    // No self-dealing
    amount >= 1_000_000,
    // Minimum 1 ADA
    deadline > 0,
    // Valid deadline
    nonce > 0,
  }
  // Valid nonce
}
