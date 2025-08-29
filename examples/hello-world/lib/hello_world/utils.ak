// Hello World Utilities - Production Helper Functions
// Clean, focused utility functions for off-chain integration

use hello_world/types.{HelloWorldDatum, HelloWorldRedeemer}

// Create a valid datum for locking funds
pub fn create_hello_datum(owner: ByteArray) -> HelloWorldDatum {
  HelloWorldDatum { owner }
}

// Create a valid redeemer for spending
pub fn create_hello_redeemer(message: ByteArray) -> HelloWorldRedeemer {
  HelloWorldRedeemer { message }
}

// Get the expected message constant
pub fn expected_message() -> ByteArray {
  "Hello, World!"
}

// Validate datum parameters (off-chain validation)
pub fn validate_datum_params(owner: ByteArray) -> Bool {
  owner != ""
  // Owner cannot be empty
}

// Validate redeemer parameters (off-chain validation)  
pub fn validate_redeemer_params(message: ByteArray) -> Bool {
  message == expected_message()
}
