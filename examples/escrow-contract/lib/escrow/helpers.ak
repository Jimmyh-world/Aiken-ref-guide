// Escrow Contract Helper Functions
// This module contains validation and utility functions for the escrow contract

/// Represents the different states an escrow can be in
pub type EscrowState {
  /// Escrow is active and waiting for completion or cancellation
  Active
  /// Escrow has been completed successfully
  Complete
  /// Escrow has been cancelled by either party
  Cancel
}

/// The datum stored with the escrow UTXO
pub type EscrowDatum {
  /// The buyer's public key hash
  buyer: ByteArray,
  /// The seller's public key hash  
  seller: ByteArray,
  /// The current state of the escrow
  state: EscrowState,
  /// The deadline for completion (slot number)
  deadline: Int,
  /// The amount of ADA in the escrow
  amount: Int,
  /// Optional additional data for extensibility
  metadata: Option<ByteArray>,
}

/// Actions that can be performed on the escrow
pub type EscrowAction {
  /// Complete the escrow (buyer action)
  CompleteEscrow {
    /// Buyer's signature
    buyer_signature: ByteArray,
  }
  /// Cancel the escrow (either party can cancel)
  CancelEscrow {
    /// Signature of the cancelling party
    canceller_signature: ByteArray,
    /// Whether the canceller is the buyer
    is_buyer: Bool,
  }
  /// Refund the escrow (seller action after deadline)
  Refund {
    /// Seller's signature
    seller_signature: ByteArray,
  }
}

/// Helper type for validation results
pub type ValidationResult {
  /// Validation passed
  Valid
  /// Validation failed with reason
  Invalid(ByteArray)
}

/// Configuration parameters for the escrow contract
pub type EscrowConfig {
  /// Minimum escrow amount in lovelace
  min_amount: Int,
  /// Maximum escrow amount in lovelace
  max_amount: Int,
  /// Minimum deadline duration in slots
  min_deadline_duration: Int,
  /// Maximum deadline duration in slots
  max_deadline_duration: Int,
}

/// Default configuration for the escrow contract
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

/// Validates that an escrow datum is well-formed
pub fn validate_escrow_datum(
  datum: EscrowDatum,
  config: EscrowConfig,
) -> ValidationResult {
  // Check amount bounds
  if datum.amount < config.min_amount {
    Invalid("Escrow amount below minimum")
  } else if datum.amount > config.max_amount {
    Invalid("Escrow amount above maximum")
  } else if datum.buyer == datum.seller {
    Invalid("Buyer and seller cannot be the same")
  } else if datum.deadline <= 0 {
    Invalid("Deadline must be positive")
  } else {
    Valid
  }
}

/// Validates that a state transition is allowed
pub fn validate_state_transition(
  current_state: EscrowState,
  action: EscrowAction,
) -> ValidationResult {
  when (current_state, action) is {
    (Active, CompleteEscrow { .. }) -> Valid
    (Active, CancelEscrow { .. }) -> Valid
    (Active, Refund { .. }) -> Valid
    (Complete, _) -> Invalid("Cannot modify completed escrow")
    (Cancel, _) -> Invalid("Cannot modify cancelled escrow")
  }
}

/// Validates that the current time is within the escrow deadline
pub fn validate_deadline(deadline: Int) -> ValidationResult {
  // Simplified deadline validation - in real implementation would check transaction validity range
  Valid
}

/// Validates that the current time is after the escrow deadline
pub fn validate_after_deadline(deadline: Int) -> ValidationResult {
  // Simplified after deadline validation
  Valid
}

/// Verifies a signature against a public key hash
pub fn verify_signature(
  signature: ByteArray,
  message: ByteArray,
  pub_key_hash: ByteArray,
) -> Bool {
  // In a real implementation, this would use proper cryptographic verification
  // For now, we'll use a simplified check that the signature is not empty
  // and the public key hash matches the expected format
  if signature == "" {
    False
  } else if pub_key_hash == "" {
    False
  } else {
    // Simplified verification - in production, use proper Ed25519 verification
    True
  }
}

/// Validates that the buyer signature is correct for the complete action
pub fn validate_buyer_signature(
  action: EscrowAction,
  datum: EscrowDatum,
) -> ValidationResult {
  when action is {
    CompleteEscrow { buyer_signature } -> {
      let message = create_completion_message(datum)
      if verify_signature(buyer_signature, message, datum.buyer) {
        Valid
      } else {
        Invalid("Invalid buyer signature")
      }
    }
    _ -> Invalid("Action is not a completion")
  }
}

/// Validates that the canceller signature is correct
pub fn validate_canceller_signature(
  action: EscrowAction,
  datum: EscrowDatum,
) -> ValidationResult {
  when action is {
    CancelEscrow { canceller_signature, is_buyer } -> {
      let message = create_cancellation_message(datum)
      let expected_signer =
        if is_buyer {
          datum.buyer
        } else {
          datum.seller
        }
      if verify_signature(canceller_signature, message, expected_signer) {
        Valid
      } else {
        Invalid("Invalid canceller signature")
      }
    }
    _ -> Invalid("Action is not a cancellation")
  }
}

/// Validates that the seller signature is correct for the refund action
pub fn validate_seller_signature(
  action: EscrowAction,
  datum: EscrowDatum,
) -> ValidationResult {
  when action is {
    Refund { seller_signature } -> {
      let message = create_refund_message(datum)
      if verify_signature(seller_signature, message, datum.seller) {
        Valid
      } else {
        Invalid("Invalid seller signature")
      }
    }
    _ -> Invalid("Action is not a refund")
  }
}

/// Creates a message for the buyer to sign when completing the escrow
fn create_completion_message(datum: EscrowDatum) -> ByteArray {
  // In a real implementation, this would create a proper message hash
  // combining the datum fields and transaction hash
  "complete_escrow"
}

/// Creates a message for the canceller to sign when cancelling the escrow
fn create_cancellation_message(datum: EscrowDatum) -> ByteArray {
  // In a real implementation, this would create a proper message hash
  "cancel_escrow"
}

/// Creates a message for the seller to sign when refunding the escrow
fn create_refund_message(datum: EscrowDatum) -> ByteArray {
  // In a real implementation, this would create a proper message hash
  "refund_escrow"
}

/// Validates that the output amount matches the escrow amount
pub fn validate_output_amount(expected_amount: Int) -> ValidationResult {
  // Simplified output validation - in real implementation would check transaction outputs
  Valid
}

/// Validates that the output goes to the correct recipient
pub fn validate_output_recipient(recipient: ByteArray) -> ValidationResult {
  // Simplified recipient validation
  Valid
}

/// Creates a new escrow datum with the updated state
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
    metadata: datum.metadata,
  }
}

/// Checks if the escrow is in a final state (cannot be modified)
pub fn is_final_state(state: EscrowState) -> Bool {
  when state is {
    Active -> False
    Complete -> True
    Cancel -> True
  }
}

/// Validates the complete escrow transaction
pub fn validate_completion_transaction(
  datum: EscrowDatum,
  action: EscrowAction,
) -> ValidationResult {
  // Validate buyer signature
  let signature_check = validate_buyer_signature(action, datum)
  if signature_check != Valid {
    signature_check
  } else {
    // Validate output goes to seller
    let recipient_check = validate_output_recipient(datum.seller)
    if recipient_check != Valid {
      recipient_check
    } else {
      // Validate output amount
      validate_output_amount(datum.amount)
    }
  }
}

/// Validates the cancellation transaction
pub fn validate_cancellation_transaction(
  datum: EscrowDatum,
  action: EscrowAction,
) -> ValidationResult {
  // Validate canceller signature
  let signature_check = validate_canceller_signature(action, datum)
  if signature_check != Valid {
    signature_check
  } else {
    when action is {
      CancelEscrow { is_buyer, .. } -> {
        let expected_recipient =
          if is_buyer {
            datum.buyer
          } else {
            datum.seller
          }
        let recipient_check = validate_output_recipient(expected_recipient)
        if recipient_check != Valid {
          recipient_check
        } else {
          validate_output_amount(datum.amount)
        }
      }
      _ -> Invalid("Invalid action type")
    }
  }
}

/// Validates the refund transaction
pub fn validate_refund_transaction(
  datum: EscrowDatum,
  action: EscrowAction,
) -> ValidationResult {
  // Validate seller signature
  let signature_check = validate_seller_signature(action, datum)
  if signature_check != Valid {
    signature_check
  } else {
    // Validate output goes to buyer
    let recipient_check = validate_output_recipient(datum.buyer)
    if recipient_check != Valid {
      recipient_check
    } else {
      validate_output_amount(datum.amount)
    }
  }
}
