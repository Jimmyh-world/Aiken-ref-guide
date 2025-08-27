use aiken/list
use hello_world/hello_world.{spend}

test spend_succeeds() {
  let owner_key = #"00010203"
  let datum = Datum { owner: owner_key }
  let redeemer = "Hello, World!"
  let context = mock_context([owner_key])
  
  spend(datum, redeemer, context)
}

test spend_fails_wrong_message() {
  let owner_key = #"00010203"
  let datum = Datum { owner: owner_key }
  let redeemer = "Wrong message"
  let context = mock_context([owner_key])
  
  !spend(datum, redeemer, context)
}

test spend_fails_wrong_signer() {
  let owner_key = #"00010203"
  let wrong_key = #"04050607"
  let datum = Datum { owner: owner_key }
  let redeemer = "Hello, World!"
  let context = mock_context([wrong_key])
  
  !spend(datum, redeemer, context)
}
