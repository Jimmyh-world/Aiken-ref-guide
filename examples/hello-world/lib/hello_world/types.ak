// Hello World Validator Types
// All custom data types used by the hello world validator

// Datum: Contains the owner's public key hash
pub type HelloWorldDatum {
  owner: ByteArray,
}

// Redeemer: Must be "Hello, World!" to spend
pub type HelloWorldRedeemer {
  message: ByteArray,
}

// Mock context for testing purposes
pub type MockContext {
  signatories: List<ByteArray>,
  validity_range: ValidityRange,
}

// Validity range for transaction testing
pub type ValidityRange {
  lower_bound: Option<Int>,
  upper_bound: Option<Int>,
}
