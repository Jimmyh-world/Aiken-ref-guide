// Escrow Contract Validator
// This validator implements a secure escrow system with state machine logic

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
  validate_completion_transaction,
  validate_cancellation_transaction,
  validate_refund_transaction,
  update_escrow_state,
  is_final_state,
  default_config,
  Valid,
  Invalid,
  CompleteEscrow,
  CancelEscrow,
  Refund,
  Active,
  Complete,
  Cancel,
}

/// Main escrow validator that handles all escrow operations
validator escrow_contract {
  /// Handles spending of escrow UTXOs
  spend(
    datum: Option<EscrowDatum>,
    redeemer: EscrowAction,
    own_ref: __OutputReference,
    context: __ScriptContext,
  ) -> Bool {
    // Handle the optional datum
    when datum is {
      Some(escrow_datum) -> {
        // Validate the escrow datum is well-formed
        let datum_validation = validate_escrow_datum(escrow_datum, default_config())
        if datum_validation != Valid {
          False
        } else {
          // Validate state transition is allowed
          let transition_validation = validate_state_transition(escrow_datum.state, redeemer)
          if transition_validation != Valid {
            False
          } else {
            // Handle different actions based on the redeemer
            when redeemer is {
              CompleteEscrow { .. } -> {
                // Complete the escrow - buyer pays seller
                validate_completion_action(escrow_datum, redeemer)
              }
              CancelEscrow { .. } -> {
                // Cancel the escrow - return funds to canceller
                validate_cancellation_action(escrow_datum, redeemer)
              }
              Refund { .. } -> {
                // Refund the escrow - seller returns funds to buyer after deadline
                validate_refund_action(escrow_datum, redeemer)
              }
            }
          }
        }
      }
      None -> False  // No datum provided, reject the transaction
    }
  }

  /// Handles minting of new escrow UTXOs (for escrow creation)
  mint(
    redeemer: EscrowAction,
    policy_id: __PolicyId,
    context: __ScriptContext,
  ) -> Bool {
    // Escrow contract doesn't mint tokens
    False
  }

  /// Handles withdrawal of escrow UTXOs (for escrow completion/cancellation)
  withdraw(
    redeemer: EscrowAction,
    credential: __Credential,
    context: __ScriptContext,
  ) -> Bool {
    // Escrow contract doesn't withdraw tokens
    False
  }
}

/// Validates a completion action (buyer completes escrow)
fn validate_completion_action(
  datum: EscrowDatum,
  action: EscrowAction,
) -> Bool {
  // Ensure escrow is active
  if datum.state != Active {
    False
  } else {
    // Validate deadline hasn't passed
    let deadline_check = validate_deadline(datum.deadline)
    if deadline_check != Valid {
      False
    } else {
      // Validate the completion transaction
      let validation = validate_completion_transaction(datum, action)
      
      when validation is {
        Valid -> True
        Invalid(_) -> False
      }
    }
  }
}

/// Validates a cancellation action (either party cancels escrow)
fn validate_cancellation_action(
  datum: EscrowDatum,
  action: EscrowAction,
) -> Bool {
  // Ensure escrow is active
  if datum.state != Active {
    False
  } else {
    // Validate deadline hasn't passed (cancellation only before deadline)
    let deadline_check = validate_deadline(datum.deadline)
    if deadline_check != Valid {
      False
    } else {
      // Validate the cancellation transaction
      let validation = validate_cancellation_transaction(datum, action)
      
      when validation is {
        Valid -> True
        Invalid(_) -> False
      }
    }
  }
}

/// Validates a refund action (seller refunds after deadline)
fn validate_refund_action(
  datum: EscrowDatum,
  action: EscrowAction,
) -> Bool {
  // Ensure escrow is active
  if datum.state != Active {
    False
  } else {
    // Validate deadline has passed (refund only after deadline)
    let deadline_check = validate_after_deadline(datum.deadline)
    if deadline_check != Valid {
      False
    } else {
      // Validate the refund transaction
      let validation = validate_refund_transaction(datum, action)
      
      when validation is {
        Valid -> True
        Invalid(_) -> False
      }
    }
  }
}
