// Hello World Validator
// This validator demonstrates the basic eUTxO model:
// 1. Lock tADA to this script with a datum
// 2. Spend only if redeemer == "Hello, World!" AND owner signs
//
// Flow: Lock → Spend (with correct redeemer + signature)

// Datum: Contains the owner's public key hash
pub type HelloWorldDatum {
  owner: ByteArray,
}

// Redeemer: Must be "Hello, World!" to spend
pub type HelloWorldRedeemer {
  message: ByteArray,
}

// Main validator function
validator hello_world(_owner_pkh: ByteArray) {
  spend(
    _datum: Option<HelloWorldDatum>,
    redeemer: HelloWorldRedeemer,
    _own_ref: __OutputReference,
    _context: __ScriptContext,
  ) {
    // 1. Validate the redeemer message
    let valid_message = redeemer.message == "Hello, World!"
    // 2. Check that the owner signed this transaction
    let owner_signed = True
    // TODO: Implement proper signature validation
    // 3. Both conditions must be true
    valid_message && owner_signed
  }

  else(_) {
    fail
  }
}
