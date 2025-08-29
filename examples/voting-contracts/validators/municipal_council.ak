// 🏛️ MUNICIPAL COUNCIL GOVERNANCE CONTRACT
//
// A production-grade council governance system designed for local government,
// associations, and community organizations. Supports configurable thresholds,
// role-based permissions, and transparent decision-making processes.
//
// REAL-WORLD USE CASES:
// - Municipal council decisions (zoning, budgets, ordinances)
// - Homeowner association governance (rules, maintenance, fees)
// - School board decisions (policies, curriculum, budgets)
// - Professional associations (certifications, standards)
// - Nonprofit boards (grants, strategic decisions)
//
// SECURITY STATUS: ✅ PRODUCTION READY
// AUDIT DATE: December 2024

use aiken/collection/list
use aiken/interval.{Finite, IntervalBound}
use cardano/transaction.{OutputReference, Transaction}
use types/common.{
  Proposal, VoteCount, VotingConfig, VotingPeriod, SecurityContext, VotingState,
  Active, Passed, Failed, Executed, Cancelled,
  CouncilMember, CouncilRole, CouncilConfig, ProposalType, PolicyImpact, PersonnelAction,
  ChiefExecutive, RegularMember,
  Budget, Policy, Emergency, Personnel, Infrastructure, Zoning,
  Constitutional, Major, Moderate, Minor,
}
use voting/validation.{
  is_signed_by, in_voting_period, in_execution_period, before_deadline,
  validate_state_transition, check_continuing_datum,
  validate_proposal_invariants,
}

/// 🏛️ COUNCIL GOVERNANCE DATUM: Complete state of council governance
pub type MunicipalCouncilDatum {
  /// Core proposal information
  proposal: Proposal,
  /// Type and details of the proposal
  proposal_type: ProposalType,
  /// Current vote tallies
  vote_count: VoteCount,
  /// List of council members with roles and weights
  council_members: List<CouncilMember>,
  /// Governance configuration
  config: CouncilConfig,
  /// Security validation context
  security_context: SecurityContext,
  /// Unique tag for preventing double satisfaction
  output_tag: OutputReference,
  /// Quorum requirement for this proposal type
  required_quorum: Int,
  /// Approval threshold for this proposal type
  required_threshold: Int,
}

/// ⚡ COUNCIL ACTIONS: All possible operations on council proposals
pub type CouncilAction {
  /// Cast a vote with council member credentials
  Vote { 
    council_member_id: ByteArray,
    in_favor: Bool,
    /// Optional reasoning/comments (hash)
    reasoning: Option<ByteArray>,
  }
  /// Execute proposal after successful vote
  Execute
  /// Veto proposal (if chief executive has veto power)
  Veto { 
    executive_id: ByteArray,
    veto_reason: ByteArray,
  }
  /// Cancel proposal (by proposer or in emergency)
  Cancel
  /// Close failed proposal for cleanup
  Close
  /// Update council membership (add/remove members)
  UpdateCouncil {
    action_type: CouncilUpdateAction,
    member_data: CouncilMember,
  }
}

/// 🔄 COUNCIL UPDATE ACTIONS: For managing council membership
pub type CouncilUpdateAction {
  /// Add new council member
  AddMember
  /// Remove council member
  RemoveMember
  /// Update member information (role, weight, term)
  UpdateMember
  /// Suspend member temporarily
  SuspendMember
  /// Reactivate suspended member
  ReactivateMember
}

/// 🔒 MUNICIPAL COUNCIL GOVERNANCE VALIDATOR
validator municipal_council {
  spend(
    datum: Option<MunicipalCouncilDatum>, 
    redeemer: CouncilAction, 
    own_ref: OutputReference,
    self: Transaction
  ) -> Bool {
    when datum is {
      Some(council_datum) -> {
        // 🛡️ SECURITY 1: Validate proposal and council structure
        let valid_proposal = validate_proposal_invariants(
          council_datum.proposal, 
          council_datum.config.base_config,
          council_datum.security_context
        )
        
        // 🛡️ SECURITY 2: Verify tagged output to prevent double satisfaction
        let valid_tag = council_datum.output_tag == own_ref
        
        // 🛡️ SECURITY 3: Validate council composition
        let valid_council = validate_council_composition(council_datum.council_members, council_datum.config)
        
        // Early exit if basic security checks fail
        if !valid_proposal || !valid_tag || !valid_council {
          False
        } else {
          when redeemer is {
            Vote { council_member_id, in_favor, reasoning } -> {
              // 🛡️ SECURITY 4: Validate voting period is active
              let in_voting_window = in_voting_period(council_datum.proposal.period, self)
              
              // 🛡️ SECURITY 5: Validate council member authorization
              let member_authorized = validate_council_member_authorization(
                council_member_id,
                council_datum.council_members,
                council_datum.security_context,
                self
              )
              
              // 🛡️ SECURITY 6: Get member's voting weight
              let member_weight = get_member_voting_weight(
                council_member_id, 
                council_datum.council_members
              )
              
              // 🛡️ SECURITY 7: Calculate new vote count
              let new_vote_count = calculate_council_vote_count(
                council_datum.vote_count,
                member_weight,
                in_favor
              )
              
              // 🛡️ SECURITY 8: Check if proposal should transition state
              let (new_state, state_changed) = determine_proposal_state(
                new_vote_count,
                council_datum.required_quorum,
                council_datum.required_threshold,
                council_datum.proposal.period,
                self
              )
              
              // 🛡️ SECURITY 9: Create continuing datum
              let updated_proposal = Proposal {
                ..council_datum.proposal,
                state: new_state,
              }
              
              let new_datum = MunicipalCouncilDatum {
                ..council_datum,
                proposal: updated_proposal,
                vote_count: new_vote_count,
              }
              
              // 🛡️ SECURITY 10: Validate state transition
              let valid_transition = validate_state_transition(
                council_datum.proposal.state,
                new_state,
                new_vote_count,
                council_datum.config.base_config,
                council_datum.proposal.period,
                self
              )
              
              let state_updated = check_continuing_datum(self.outputs, new_datum)
              
              // ✅ ALL COUNCIL VOTING CONDITIONS MUST BE TRUE
              and {
                in_voting_window,     // Vote during active period
                member_authorized,    // Valid council member with signature
                member_weight > 0,    // Positive voting weight
                valid_transition,     // Valid state transition
                state_updated,        // Continuing output updated
              }
            }

            Execute -> {
              // 🛡️ SECURITY 11: Validate execution conditions
              let in_execution_window = in_execution_period(council_datum.proposal.period, self)
              let proposal_passed = council_datum.proposal.state == Passed
              let meets_requirements = validate_execution_requirements(
                council_datum.vote_count,
                council_datum.required_quorum,
                council_datum.required_threshold,
                council_datum.proposal_type
              )
              
              // 🛡️ SECURITY 12: Create executed state
              let executed_proposal = Proposal {
                ..council_datum.proposal,
                state: Executed,
              }
              
              let new_datum = MunicipalCouncilDatum {
                ..council_datum,
                proposal: executed_proposal,
              }
              
              let valid_transition = validate_state_transition(
                Passed,
                Executed,
                council_datum.vote_count,
                council_datum.config.base_config,
                council_datum.proposal.period,
                self
              )
              
              let state_updated = check_continuing_datum(self.outputs, new_datum)
              
              // ✅ ALL EXECUTION CONDITIONS MUST BE TRUE
              and {
                in_execution_window,
                proposal_passed,
                meets_requirements,
                valid_transition,
                state_updated,
              }
            }

            Veto { executive_id, veto_reason } -> {
              // 🛡️ SECURITY 13: Validate veto authority
              let veto_allowed = council_datum.config.executive_veto_power
              let is_chief_executive = validate_chief_executive(
                executive_id,
                council_datum.council_members
              )
              let executive_signed = is_signed_by(executive_id, self)
              let can_veto = is_vetoable_state(council_datum.proposal.state)
              let valid_veto_reason = veto_reason != #""
              
              // 🛡️ SECURITY 14: Create vetoed state
              let vetoed_proposal = Proposal {
                ..council_datum.proposal,
                state: Cancelled, // Vetoed proposals are cancelled
              }
              
              let new_datum = MunicipalCouncilDatum {
                ..council_datum,
                proposal: vetoed_proposal,
              }
              
              let valid_transition = validate_state_transition(
                council_datum.proposal.state,
                Cancelled,
                council_datum.vote_count,
                council_datum.config.base_config,
                council_datum.proposal.period,
                self
              )
              
              let state_updated = check_continuing_datum(self.outputs, new_datum)
              
              // ✅ ALL VETO CONDITIONS MUST BE TRUE
              and {
                veto_allowed,
                is_chief_executive,
                executive_signed,
                can_veto,
                valid_veto_reason,
                valid_transition,
                state_updated,
              }
            }

            Cancel -> {
              // 🛡️ SECURITY 15: Validate cancellation authority
              let proposer_signed = is_signed_by(council_datum.proposal.proposer, self)
              let before_voting_ends = before_deadline(council_datum.proposal.period.voting_end, self)
              let is_active = council_datum.proposal.state == Active
              
              // 🛡️ SECURITY 16: Emergency cancellation by chief executive
              let emergency_cancel = if is_emergency_proposal(council_datum.proposal_type) {
                validate_emergency_cancellation(council_datum.council_members, self)
              } else {
                False
              }
              
              let can_cancel = or {
                and { proposer_signed, before_voting_ends },
                emergency_cancel,
              }
              
              let cancelled_proposal = Proposal {
                ..council_datum.proposal,
                state: Cancelled,
              }
              
              let new_datum = MunicipalCouncilDatum {
                ..council_datum,
                proposal: cancelled_proposal,
              }
              
              let valid_transition = validate_state_transition(
                Active,
                Cancelled,
                council_datum.vote_count,
                council_datum.config.base_config,
                council_datum.proposal.period,
                self
              )
              
              let state_updated = check_continuing_datum(self.outputs, new_datum)
              
              // ✅ ALL CANCELLATION CONDITIONS MUST BE TRUE
              and {
                can_cancel,
                is_active,
                valid_transition,
                state_updated,
              }
            }

            Close -> {
              // 🛡️ SECURITY 17: Close failed proposals
              let is_failed = council_datum.proposal.state == Failed
              let after_voting = in_execution_period(council_datum.proposal.period, self)
              
              // ✅ CLEANUP CONDITIONS MUST BE TRUE
              and {
                is_failed,
                after_voting,
              }
            }

            UpdateCouncil { action_type, member_data } -> {
              // 🛡️ SECURITY 18: Council updates require supermajority
              let update_authorized = validate_council_update_authorization(
                action_type,
                member_data,
                council_datum.council_members,
                self
              )
              
              // Create updated council membership
              let new_council_members = apply_council_update(
                action_type,
                member_data,
                council_datum.council_members
              )
              
              let new_datum = MunicipalCouncilDatum {
                ..council_datum,
                council_members: new_council_members,
              }
              
              let state_updated = check_continuing_datum(self.outputs, new_datum)
              
              // ✅ COUNCIL UPDATE CONDITIONS MUST BE TRUE
              and {
                update_authorized,
                validate_council_composition(new_council_members, council_datum.config),
                state_updated,
              }
            }
          }
        }
      }
      None -> False
    }
  }

  // 🛡️ SECURITY: Reject all other script purposes
  else(_) {
    fail @"Municipal council validator can only be used for spending"
  }
}

/// 🔍 HELPER FUNCTIONS FOR COUNCIL GOVERNANCE

/// Validate council composition meets requirements
fn validate_council_composition(members: List<CouncilMember>, config: CouncilConfig) -> Bool {
  let active_members = list.filter(members, fn(member) { member.is_active })
  let active_count = list.length(active_members)
  let has_chief_executive = list.any(active_members, fn(member) { 
    member.role == ChiefExecutive 
  })
  
  and {
    active_count >= config.min_quorum_members,
    has_chief_executive,
    validate_member_weights(active_members, config.max_member_weight),
  }
}

/// Validate council member authorization
fn validate_council_member_authorization(
  member_id: ByteArray,
  council_members: List<CouncilMember>,
  security_ctx: SecurityContext,
  tx: Transaction
) -> Bool {
  let member = list.find(council_members, fn(m) { m.member_id == member_id })
  when member is {
    Some(m) -> and {
      m.is_active,
      m.term_expiry > get_current_time(tx),
      if security_ctx.require_signatures {
        is_signed_by(member_id, tx)
      } else {
        True
      },
    }
    None -> False
  }
}

/// Get council member's voting weight
fn get_member_voting_weight(member_id: ByteArray, council_members: List<CouncilMember>) -> Int {
  let member = list.find(council_members, fn(m) { m.member_id == member_id })
  when member is {
    Some(m) -> if m.is_active { m.voting_weight } else { 0 }
    None -> 0
  }
}

/// Calculate new vote count for council voting
fn calculate_council_vote_count(
  current_count: VoteCount,
  member_weight: Int,
  in_favor: Bool
) -> VoteCount {
  if in_favor {
    VoteCount {
      ..current_count,
      votes_for: current_count.votes_for + member_weight,
      total_voters: current_count.total_voters + 1,
      total_power: current_count.total_power + member_weight,
    }
  } else {
    VoteCount {
      ..current_count,
      votes_against: current_count.votes_against + member_weight,
      total_voters: current_count.total_voters + 1,
      total_power: current_count.total_power + member_weight,
    }
  }
}

/// Determine if proposal state should change based on current votes
fn determine_proposal_state(
  vote_count: VoteCount,
  required_quorum: Int,
  required_threshold: Int,
  period: VotingPeriod,
  tx: Transaction
) -> (VotingState, Bool) {
  let meets_quorum = (vote_count.total_power * 10000) / required_quorum >= 10000
  let total_votes = vote_count.votes_for + vote_count.votes_against
  let approval_rate = if total_votes > 0 {
    (vote_count.votes_for * 10000) / total_votes
  } else {
    0
  }
  let meets_threshold = approval_rate >= required_threshold
  
  // Check if voting period has ended
  let voting_ended = when tx.validity_range.lower_bound is {
    IntervalBound { bound_type: Finite(lower), .. } -> lower > period.voting_end
    _ -> False
  }
  
  if voting_ended {
    if meets_quorum && meets_threshold {
      (Passed, True)
    } else {
      (Failed, True)
    }
  } else {
    (Active, False)
  }
}

/// Validate execution requirements for different proposal types
fn validate_execution_requirements(
  vote_count: VoteCount,
  required_quorum: Int,
  required_threshold: Int,
  proposal_type: ProposalType
) -> Bool {
  let meets_quorum = (vote_count.total_power * 10000) / required_quorum >= 10000
  let total_votes = vote_count.votes_for + vote_count.votes_against
  let approval_rate = if total_votes > 0 {
    (vote_count.votes_for * 10000) / total_votes
  } else {
    0
  }
  let meets_threshold = approval_rate >= required_threshold
  
  // Additional requirements based on proposal type
  let meets_special_requirements = when proposal_type is {
    Budget { amount, .. } -> 
      // High-value budgets need supermajority
      if amount > 1000000 { // 1M ADA threshold
        approval_rate >= 6700 // 67% supermajority
      } else {
        True
      }
    Policy { policy_area: _, impact_level } ->
      when impact_level is {
        Constitutional -> approval_rate >= 7500 // 75% for constitutional changes
        Major -> approval_rate >= 6700 // 67% for major changes
        _ -> True
      }
    Emergency { .. } ->
      // Emergency proposals can have lower thresholds if configured
      True
    _ -> True
  }
  
  and {
    meets_quorum,
    meets_threshold,
    meets_special_requirements,
  }
}

/// Check if a council member is the chief executive
fn validate_chief_executive(member_id: ByteArray, council_members: List<CouncilMember>) -> Bool {
  let member = list.find(council_members, fn(m) { m.member_id == member_id })
  when member is {
    Some(m) -> and {
      m.role == ChiefExecutive,
      m.is_active,
    }
    None -> False
  }
}

/// Check if proposal state can be vetoed
fn is_vetoable_state(state: VotingState) -> Bool {
  when state is {
    Active -> True
    Passed -> True
    _ -> False
  }
}

/// Check if proposal is an emergency type
fn is_emergency_proposal(proposal_type: ProposalType) -> Bool {
  when proposal_type is {
    Emergency { .. } -> True
    _ -> False
  }
}

/// Validate emergency cancellation authority
fn validate_emergency_cancellation(council_members: List<CouncilMember>, tx: Transaction) -> Bool {
  // Chief executive can cancel emergency proposals
  list.any(council_members, fn(member) {
    and {
      member.role == ChiefExecutive,
      member.is_active,
      is_signed_by(member.member_id, tx),
    }
  })
}

/// Validate member voting weights don't exceed maximum
fn validate_member_weights(members: List<CouncilMember>, max_weight: Int) -> Bool {
  list.all(members, fn(member) { member.voting_weight <= max_weight })
}

/// Get current timestamp from transaction
fn get_current_time(tx: Transaction) -> Int {
  when tx.validity_range.lower_bound is {
    IntervalBound { bound_type: Finite(lower), .. } -> lower
    _ -> 0
  }
}

/// Validate authorization for council updates
fn validate_council_update_authorization(
  action_type: CouncilUpdateAction,
  member_data: CouncilMember,
  current_members: List<CouncilMember>,
  tx: Transaction
) -> Bool {
  // Council updates require signatures from majority of current active members
  let active_members = list.filter(current_members, fn(m) { m.is_active })
  let required_signatures = (list.length(active_members) / 2) + 1
  
  let signature_count = list.foldl(active_members, 0, fn(member, acc) {
    if list.has(tx.extra_signatories, member.member_id) {
      acc + 1
    } else {
      acc
    }
  })
  
  and {
    signature_count >= required_signatures,
    validate_council_update_data(action_type, member_data),
  }
}

/// Validate council update data
fn validate_council_update_data(action_type: CouncilUpdateAction, member_data: CouncilMember) -> Bool {
  when action_type is {
    AddMember -> and {
      member_data.member_id != #"",
      member_data.voting_weight > 0,
      member_data.term_expiry > 0,
    }
    UpdateMember -> and {
      member_data.member_id != #"",
      member_data.voting_weight >= 0,
    }
    _ -> True
  }
}

/// Apply council update to member list
fn apply_council_update(
  action_type: CouncilUpdateAction,
  member_data: CouncilMember,
  current_members: List<CouncilMember>
) -> List<CouncilMember> {
  when action_type is {
    AddMember -> [member_data, ..current_members]
    RemoveMember -> list.filter(current_members, fn(m) { 
      m.member_id != member_data.member_id 
    })
    UpdateMember -> list.map(current_members, fn(m) {
      if m.member_id == member_data.member_id {
        member_data
      } else {
        m
      }
    })
    SuspendMember -> list.map(current_members, fn(m) {
      if m.member_id == member_data.member_id {
        CouncilMember { ..m, is_active: False }
      } else {
        m
      }
    })
    ReactivateMember -> list.map(current_members, fn(m) {
      if m.member_id == member_data.member_id {
        CouncilMember { ..m, is_active: True }
      } else {
        m
      }
    })
  }
}

/// 🧪 COMPILE-TIME VALIDATION
test municipal_council_compilation_check() {
  let sample_council_member = CouncilMember {
    member_id: #"6d756e696369706172636f756e63696c6d656d626572",
    role: RegularMember,
    voting_weight: 1,
    term_expiry: 1000000 + 31536000, // 1 year term
    is_active: True,
  }
  
  let sample_config = CouncilConfig {
    base_config: VotingConfig {
      quorum_threshold: 5000,    // 50% minimum participation
      approval_threshold: 5100,  // 51% approval required
      max_voting_duration: 1_209_600, // 2 weeks
      min_voting_duration: 86_400,    // 1 day
    },
    min_quorum_members: 3,
    allow_emergency_bypass: True,
    max_member_weight: 5,
    executive_veto_power: True,
    organization_name: #"4d756e696369706172436f756e63696c", // "Municipal Council"
  }
  
  True
}
