// 🎓 EDUCATIONAL SECURITY TUTORIAL - INTENTIONAL VULNERABILITIES
// 
// ⚠️ WARNING: EDUCATIONAL CONTENT ONLY - NEVER DEPLOY TO PRODUCTION
// This validator contains INTENTIONAL security vulnerabilities for learning purposes
//
// 🎯 LEARNING OBJECTIVES:
// ✓ Understand common security anti-patterns
// ✓ Learn to identify placeholder security
// ✓ Practice security audit techniques
// ✓ See real-world impact of poor validation
//
// 🚨 VULNERABILITIES DEMONSTRATED:
// ❌ Admin signature validation hardcoded to `True` - ANYONE CAN MINT
// ❌ No actual transaction context validation  
// ❌ Allows unlimited minting by any user
// ❌ Claims "controlled minting" but has no controls
//
// 📚 STATUS: Educational demonstration - study these anti-patterns to avoid them

use aiken/collection/list
use cardano/transaction.{Transaction}

// Redeemer defines possible actions for the fungible token
pub type Action {
  Mint { amount: Int }
  Burn { amount: Int }
}

// 🎓 EDUCATIONAL: Parameterized with admin's public key hash for "controlled" minting
// In this educational version, we'll show what happens with flawed validation
validator fungible_token(admin_pkh: ByteArray) {
  mint(redeemer: Action, _datum: Void, context: Transaction) {
    when redeemer is {
      Mint { amount } -> {
        // 🚨 VULNERABILITY DEMONSTRATION #1: Placeholder admin validation
        let admin_signed = validate_admin_signature(admin_pkh, context)
        
        // 🚨 VULNERABILITY DEMONSTRATION #2: Basic validation that looks secure but isn't
        let valid_amount = validate_mint_amount(amount)
        
        // ❌ EDUCATIONAL FLAW: This appears secure but the functions below return True
        and {
          admin_signed,     // ❌ Always True - anyone can mint!
          valid_amount,     // ❌ Always True - any amount allowed!
        }
      }
      Burn { amount } -> {
        // 🎓 EDUCATIONAL NOTE: Burning is typically less restricted
        // But even this validation is flawed for educational purposes
        validate_burn_amount(amount)  // ❌ Always True
      }
    }
  }
  
  else(_) {
    fail
  }
}

// 🚨 SECURITY VULNERABILITY #1: Placeholder admin signature validation
// 🎓 EDUCATIONAL: This function should check real signatures but doesn't!
fn validate_admin_signature(_admin_pkh: ByteArray, _context: Transaction) -> Bool {
  // ❌ CRITICAL FLAW: Always returns True regardless of who calls it
  // 🎓 LESSON: Look for functions that don't use their parameters!
  True
}

// 🚨 SECURITY VULNERABILITY #2: Placeholder amount validation  
// 🎓 EDUCATIONAL: This function claims to validate amounts but doesn't!
fn validate_mint_amount(_amount: Int) -> Bool {
  // ❌ CRITICAL FLAW: Should check amount > 0 and other business rules
  // 🎓 LESSON: Always validate input parameters!
  True
}

// 🚨 SECURITY VULNERABILITY #3: Placeholder burn validation
// 🎓 EDUCATIONAL: Even "safer" operations need real validation
fn validate_burn_amount(_amount: Int) -> Bool {
  // ❌ FLAW: Should check amount < 0 for burns
  // 🎓 LESSON: Negative values for burning, positive for minting
  True
}

// 🎓 EDUCATIONAL EXERCISE: How would you fix these functions?
// 
// SECURE VERSION WOULD LOOK LIKE:
//
// fn validate_admin_signature(admin_pkh: ByteArray, context: Transaction) -> Bool {
//   list.has(context.extra_signatories, admin_pkh)
// }
//
// fn validate_mint_amount(amount: Int) -> Bool {
//   amount > 0
// }
//
// fn validate_burn_amount(amount: Int) -> Bool {
//   amount < 0  // Negative amounts represent burning
// }

// 🎓 LEARNING CHECKPOINT:
// Can you identify why this validator would allow anyone to mint unlimited tokens?
// What specific lines would an attacker exploit?
// How would you test for these vulnerabilities?