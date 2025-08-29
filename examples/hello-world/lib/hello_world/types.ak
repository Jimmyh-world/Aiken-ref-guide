// Hello World Types - Production Grade
// Clean, focused type definitions

// Datum: Contains the owner who can spend the UTxO
pub type HelloWorldDatum {
  owner: ByteArray,
}

// Public key hash of the owner

// Redeemer: The message that must match exactly
pub type HelloWorldRedeemer {
  message: ByteArray,
}
// Must be "Hello, World!" to succeed
