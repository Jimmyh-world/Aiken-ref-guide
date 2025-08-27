use aiken/list

type Datum {
  owner: ByteArray,
}

validator {
  spend(datum: Datum, redeemer: ByteArray, context: ScriptContext) -> Bool {
    let tx = context.transaction
    
    let must_say_hello = redeemer == "Hello, World!"
    let must_be_signed = list.has(tx.extra_signatories, datum.owner)
    
    and {
      must_say_hello,
      must_be_signed,
    }
  }
}
