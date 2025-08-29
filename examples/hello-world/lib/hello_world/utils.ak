// Hello World Validator Utilities
// Reusable helper functions for the hello world validator

use hello_world/types.{HelloWorldDatum, HelloWorldRedeemer}

// Check if a list contains a specific element
fn list_has(list: List<ByteArray>, item: ByteArray) -> Bool {
  when list is {
    [] -> False
    [head, ..tail] ->
      if head == item {
        True
      } else {
        list_has(tail, item)
      }
  }
}

// Validate that the owner signed this transaction
pub fn validate_signature(
  owner: ByteArray,
  signatories: List<ByteArray>,
) -> Bool {
  list_has(signatories, owner)
}

// Validate that the redeemer message matches expected value
pub fn validate_message(message: ByteArray, expected: ByteArray) -> Bool {
  message == expected
}

// Helper function to create hello world message
pub fn hello_world_message() -> ByteArray {
  "Hello, World!"
}

// Helper function to create datum
pub fn create_datum(owner: ByteArray) -> HelloWorldDatum {
  HelloWorldDatum { owner }
}

// Helper function to create redeemer
pub fn create_redeemer(message: ByteArray) -> HelloWorldRedeemer {
  HelloWorldRedeemer { message }
}
