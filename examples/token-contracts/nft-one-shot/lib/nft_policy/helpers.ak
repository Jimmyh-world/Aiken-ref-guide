use aiken/collection/dict
// Helper functions for NFT One-Shot Policy
// Production-ready validation helpers

use aiken/collection/list
use cardano/assets.{Value}
use cardano/transaction.{Input, OutputReference}

// Helper function to validate UTxO consumption
pub fn validate_utxo_consumed(
  inputs: List<Input>,
  required_utxo: OutputReference,
) -> Bool {
  list.any(inputs, fn(input) { input.output_reference == required_utxo })
}

// Helper function to calculate total minted tokens (excluding ADA)
pub fn calculate_total_minted(mint_value: Value) -> Int {
  let non_ada_value = assets.without_lovelace(mint_value)
  let policy_dict = assets.to_dict(non_ada_value)
  policy_dict
    |> dict.foldl(
        0,
        fn(_policy_id, asset_dict, acc) {
          acc + dict.foldl(
            asset_dict,
            0,
            fn(_asset_name, quantity, sum) { sum + quantity },
          )
        },
      )
}

// Helper function to validate one-shot minting parameters
pub fn validate_one_shot_mint(
  token_name: ByteArray,
  utxo_ref: OutputReference,
  total_minted: Int,
) -> Bool {
  and {
    token_name != "",
    // Non-empty token name
    utxo_ref.output_index >= 0,
    // Valid output index
    total_minted == 1,
  }
  // Exactly one token minted
}

// Helper function to validate burning parameters
pub fn validate_burn_operation(token_name: ByteArray, total_burned: Int) -> Bool {
  and {
    token_name != "",
    // Non-empty token name
    total_burned < 0,
  }
  // Negative value for burning
}

// Helper function to create UTxO reference from transaction hash and index
pub fn create_utxo_reference(
  transaction_hash: ByteArray,
  output_index: Int,
) -> OutputReference {
  OutputReference { transaction_id: transaction_hash, output_index }
}

// Validation function for off-chain use
pub fn validate_nft_mint_params(
  token_name: ByteArray,
  utxo_ref: OutputReference,
) -> Bool {
  and {
    token_name != "",
    // Non-empty token name
    utxo_ref.output_index >= 0,
  }
  // Valid output index
}
