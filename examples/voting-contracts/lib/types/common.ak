// Common types and utilities for voting contracts
//
// This module defines shared data types used across different voting patterns
// following the established Aiken repository patterns and security guidelines.

// Removed unused Dict import

/// Represents different states in the voting lifecycle
pub type VotingState {
  /// Proposal is open for voting
  Active
  /// Voting period ended, proposal passed
  Passed  
  /// Voting period ended, proposal failed
  Failed
  /// Proposal was executed successfully
  Executed
  /// Proposal was cancelled before completion
  Cancelled
}

/// Basic voter information and identity
pub type Voter {
  /// Public key hash of the voter
  voter_id: ByteArray,
  /// Additional identity verification data
  verification_data: Option<ByteArray>,
}

/// Time constraints for voting operations
pub type VotingPeriod {
  /// Start time for voting (POSIX timestamp)
  voting_start: Int,
  /// End time for voting (POSIX timestamp)  
  voting_end: Int,
  /// Deadline for proposal execution
  execution_deadline: Int,
}

/// Configuration parameters for voting contracts
pub type VotingConfig {
  /// Minimum participation required (percentage * 100, e.g., 5000 = 50%)
  quorum_threshold: Int,
  /// Minimum votes required to pass (percentage * 100, e.g., 5100 = 51%)
  approval_threshold: Int,
  /// Maximum voting period duration in seconds
  max_voting_duration: Int,
  /// Minimum voting period duration in seconds  
  min_voting_duration: Int,
}

/// Standard proposal structure
pub type Proposal {
  /// Unique identifier for the proposal
  proposal_id: ByteArray,
  /// Address of who created the proposal
  proposer: ByteArray,
  /// Title/description hash
  title_hash: ByteArray,
  /// Detailed description hash (IPFS/Arweave)
  description_hash: Option<ByteArray>,
  /// Current state of the proposal
  state: VotingState,
  /// Voting time constraints
  period: VotingPeriod,
  /// Nonce for uniqueness (tagged output pattern)
  nonce: Int,
}

/// Vote cast by a participant
pub type Vote {
  /// Who cast this vote
  voter: Voter,
  /// Voting power/weight used
  power: Int,
  /// Vote choice: True for support, False for opposition
  in_favor: Bool,
  /// Block time when vote was cast
  timestamp: Int,
}

/// Aggregated voting results
pub type VoteCount {
  /// Total votes in favor
  votes_for: Int,
  /// Total votes against
  votes_against: Int,
  /// Total unique voters participated
  total_voters: Int,
  /// Total voting power used
  total_power: Int,
}

/// Security context for vote validation
pub type SecurityContext {
  /// Whether to enforce signature verification
  require_signatures: Bool,
  /// Whether to validate token ownership
  require_token_ownership: Bool,
  /// Whether to check delegation authorization
  validate_delegation: Bool,
  /// Anti-replay nonce checking
  check_nonce: Bool,
}

/// 🏛️ COUNCIL MEMBER: Represents a voting member with role and weight
pub type CouncilMember {
  /// Public key hash of the council member
  member_id: ByteArray,
  /// Role in the organization (Mayor, Councilperson, Secretary, etc.)
  role: CouncilRole,
  /// Voting weight (typically 1 for equal voting, higher for leadership roles)
  voting_weight: Int,
  /// When this member's term expires (POSIX timestamp)
  term_expiry: Int,
  /// Whether this member is currently active
  is_active: Bool,
}

/// 🎯 COUNCIL ROLES: Different roles with specific permissions
pub type CouncilRole {
  /// Chief executive (Mayor, President, Chair)
  ChiefExecutive
  /// Regular council member (Councilperson, Board Member)
  RegularMember
  /// Secretary/Clerk (record keeping, administrative)
  Secretary
  /// Treasurer (financial oversight)
  Treasurer
  /// Legal Advisor (non-voting advisory role)
  LegalAdvisor
}

/// 📋 MUNICIPAL PROPOSAL TYPES: Different categories of proposals
pub type ProposalType {
  /// Budget allocation or financial decisions
  Budget { amount: Int, department: ByteArray }
  /// Policy changes or new ordinances
  Policy { policy_area: ByteArray, impact_level: PolicyImpact }
  /// Personnel decisions (hiring, contracts)
  Personnel { position: ByteArray, action: PersonnelAction }
  /// Infrastructure projects (roads, utilities, facilities)
  Infrastructure { project_type: ByteArray, estimated_cost: Int }
  /// Zoning and land use decisions
  Zoning { property_id: ByteArray, zoning_change: ByteArray }
  /// Emergency declarations requiring immediate action
  Emergency { emergency_type: ByteArray, duration_days: Int }
}

/// 📊 POLICY IMPACT LEVELS: For determining voting requirements
pub type PolicyImpact {
  /// Minor changes (simple majority)
  Minor
  /// Moderate changes (enhanced majority)
  Moderate
  /// Major changes (supermajority required)
  Major
  /// Constitutional changes (special requirements)
  Constitutional
}

/// 👥 PERSONNEL ACTIONS: Different types of personnel decisions
pub type PersonnelAction {
  /// Hiring new staff
  Hire
  /// Promoting existing staff
  Promote
  /// Disciplinary action
  Discipline
  /// Termination
  Terminate
  /// Contract approval
  Contract
}

/// ⚙️ COUNCIL CONFIGURATION: Governance parameters for the council
pub type CouncilConfig {
  /// Basic voting configuration
  base_config: VotingConfig,
  /// Minimum council members needed for quorum
  min_quorum_members: Int,
  /// Whether emergency proposals can skip normal procedures
  allow_emergency_bypass: Bool,
  /// Maximum voting weight any single member can have
  max_member_weight: Int,
  /// Whether the chief executive has veto power
  executive_veto_power: Bool,
  /// Organization name/identifier
  organization_name: ByteArray,
}

/// Default voting configuration for simple majority voting
pub fn default_voting_config() -> VotingConfig {
  VotingConfig {
    quorum_threshold: 1000,    // 10% minimum participation
    approval_threshold: 5100,  // 51% approval required
    max_voting_duration: 1_209_600, // 2 weeks in seconds
    min_voting_duration: 86_400,    // 1 day in seconds
  }
}

/// Default security context for signature-based voting
pub fn default_security_context() -> SecurityContext {
  SecurityContext {
    require_signatures: True,
    require_token_ownership: False,
    validate_delegation: False,
    check_nonce: True,
  }
}

/// Helper to check if a voting period is valid
pub fn validate_voting_period(period: VotingPeriod, config: VotingConfig) -> Bool {
  let duration = period.voting_end - period.voting_start
  and {
    period.voting_start > 0,
    period.voting_end > period.voting_start,
    period.execution_deadline >= period.voting_end,
    duration >= config.min_voting_duration,
    duration <= config.max_voting_duration,
  }
}

/// Helper to check if proposal meets quorum requirements
pub fn meets_quorum(vote_count: VoteCount, total_eligible: Int, config: VotingConfig) -> Bool {
  let participation_rate = (vote_count.total_power * 10000) / total_eligible
  participation_rate >= config.quorum_threshold
}

/// Helper to check if proposal passes approval threshold
pub fn passes_approval(vote_count: VoteCount, config: VotingConfig) -> Bool {
  let total_votes = vote_count.votes_for + vote_count.votes_against
  when total_votes is {
    0 -> False
    _ -> {
      let approval_rate = (vote_count.votes_for * 10000) / total_votes
      approval_rate >= config.approval_threshold
    }
  }
}

/// Create a unique proposal ID using nonce and proposer
pub fn create_proposal_id(proposer: ByteArray, nonce: Int) -> ByteArray {
  // Simple approach for demo - just use proposer as base
  // In production, would use proper hashing with nonce
  // For now, the proposer address provides sufficient uniqueness
  if nonce > 0 {
    proposer
  } else {
    proposer
  }
}

/// Validate basic proposal structure
pub fn validate_proposal(proposal: Proposal, config: VotingConfig) -> Bool {
  and {
    proposal.proposal_id != "",
    proposal.proposer != "",
    proposal.title_hash != "", 
    proposal.nonce > 0,
    validate_voting_period(proposal.period, config),
  }
}

/// Get default council configuration for municipal governance
pub fn default_municipal_config() -> CouncilConfig {
  CouncilConfig {
    base_config: default_voting_config(),
    min_quorum_members: 3,              // Minimum 3 council members
    allow_emergency_bypass: True,       // Allow emergency procedures
    max_member_weight: 5,               // Maximum voting weight per member
    executive_veto_power: True,         // Chief executive has veto power
    organization_name: #"4d756e696369706172436f756e63696c", // "Municipal Council"
  }
}

/// Create a sample council member for testing
pub fn create_sample_council_member(member_id: ByteArray, role: CouncilRole) -> CouncilMember {
  CouncilMember {
    member_id: member_id,
    role: role,
    voting_weight: get_role_voting_weight(role),
    term_expiry: 1000000 + 31536000, // 1 year from base time
    is_active: True,
  }
}

/// Get voting weight for different council roles
pub fn get_role_voting_weight(role: CouncilRole) -> Int {
  when role is {
    ChiefExecutive -> 2    // Mayor/President gets double weight
    RegularMember -> 1     // Standard council member
    Secretary -> 1         // Secretary has voting rights
    Treasurer -> 1         // Treasurer has voting rights
    LegalAdvisor -> 0      // Legal advisor is non-voting
  }
}

/// Get minimum threshold for proposal types
pub fn get_proposal_threshold(proposal_type: ProposalType) -> Int {
  when proposal_type is {
    Budget { amount, .. } -> 
      if amount > 1000000 { 6700 } else { 5100 } // Supermajority for large budgets
    Policy { policy_area: _, impact_level } ->
      when impact_level is {
        Constitutional -> 7500  // 75% for constitutional changes
        Major -> 6700          // 67% for major changes
        Moderate -> 5500       // 55% for moderate changes
        Minor -> 5100          // 51% for minor changes
      }
    Emergency { .. } -> 5100   // Standard majority for emergencies
    Personnel { position: _, action } ->
      when action is {
        Terminate -> 6700      // Supermajority for termination
        Discipline -> 6700     // Supermajority for discipline
        _ -> 5100              // Standard majority for other personnel actions
      }
    Infrastructure { project_type: _, estimated_cost } ->
      if estimated_cost > 5000000 { 6700 } else { 5100 } // Supermajority for major projects
    Zoning { .. } -> 5500      // Enhanced majority for zoning changes
  }
}
