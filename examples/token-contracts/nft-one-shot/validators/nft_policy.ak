use aiken/collection/dict
// Production-Ready NFT One-Shot Minting Policy
// Implements secure one-shot minting with UTxO reference validation

use aiken/collection/list
use cardano/assets.{Value}
use cardano/transaction.{Input, OutputReference, Transaction}

// Redeemer for minting/burning actions
pub type NftAction {
  Mint { token_name: ByteArray }
  Burn { token_name: ByteArray }
}

// Parameterized validator - the UTxO reference ensures uniqueness
validator one_shot_nft(utxo_ref: OutputReference) {
  mint(redeemer: NftAction, _datum: Void, self: Transaction) {
    when redeemer is {
      Mint { token_name } -> {
        // 1. SECURITY: Ensure the unique UTxO is being consumed
        let utxo_consumed =
          list.any(
            self.inputs,
            fn(input) { input.output_reference == utxo_ref },
          )

        // 2. SECURITY: Validate exactly one token is minted (total across all policies)
        // Use the same approach as documentation examples
        let minted_value = assets.without_lovelace(self.mint)
        let policy_dict = assets.to_dict(minted_value)
        let total_minted =
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

        // 3. SECURITY: Basic validation that we're minting something
        let valid_token_name = token_name != ""

        // 4. SECURITY: All conditions must be satisfied for one-shot NFT
        and {
          utxo_consumed,
          // UTxO reference consumed (uniqueness)
          total_minted == 1,
          // Exactly 1 token minted total
          valid_token_name,
        }
      }
      // Valid token name
      Burn { token_name } -> {
        // SECURITY: Burning is allowed - ledger ensures user owns the tokens
        // For burning, we validate that the mint value is negative (burning operation)
        let minted_value = assets.without_lovelace(self.mint)
        let policy_dict = assets.to_dict(minted_value)
        let total_burned =
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
        and {
          total_burned < 0,
          // Must be negative for burning
          token_name != "",
        }
      }
    }
    // Valid token name
  }

  else(_) {
    fail
  }
}

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
