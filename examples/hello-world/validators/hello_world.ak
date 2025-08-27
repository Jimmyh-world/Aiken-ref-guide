use aiken/list

// The datum holds the public key hash of the UTxO's owner.
type Datum {
  owner: ByteArray,
}

validator {
  // This is a spending validator.
  spend(datum: Datum, redeemer: ByteArray, context: ScriptContext) -> Bool {
    let tx = context.transaction

    // Condition 1: The redeemer message must be "Hello, World!"
    let must_say_hello = redeemer == "Hello, World!"

    // Condition 2: The transaction must be signed by the owner.
    let must_be_signed = list.has(tx.extra_signatories, datum.owner)

    // Both conditions must be true for the validator to succeed.
    and {
      must_say_hello,
      must_be_signed,
    }
  }
} 