// Hello World Validator
// This validator demonstrates the basic eUTxO model:
// 1. Lock tADA to this script with a datum
// 2. Spend only if redeemer == "Hello, World!" AND owner signs
//
// Flow: Lock → Spend (with correct redeemer + signature)

use hello_world/types.{HelloWorldDatum, HelloWorldRedeemer}
use hello_world/utils.{
  hello_world_message, validate_message, validate_signature,
}

// Main validator function
validator hello_world(_owner_pkh: ByteArray) {
  spend(
    datum: Option<HelloWorldDatum>,
    redeemer: HelloWorldRedeemer,
    _own_ref: __OutputReference,
    context: __ScriptContext,
  ) {
    // 1. Validate the redeemer message
    let valid_message =
      validate_message(redeemer.message, hello_world_message())
    // 2. Check that the owner signed this transaction
    let owner_signed =
      when datum is {
        Some(d) -> list.has(context.tx.extra_signatories, d.owner)
        None -> False
      }
    // 3. Both conditions must be true
    valid_message && owner_signed
  }

  else(_) {
    fail
  }
}
