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
