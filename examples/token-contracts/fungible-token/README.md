# Controlled Fungible Token Contract

## Overview

This contract implements a **controlled fungible token minting policy** that demonstrates admin-controlled token supply management. It follows the controlled minting pattern from the Aiken documentation and provides secure role-based access control for token operations.

## Key Features

- **Admin-Controlled Minting**: Only the designated admin can mint new tokens
- **Unrestricted Burning**: Anyone can burn their own tokens (negative amounts)
- **Flexible Supply Management**: Admin can mint any positive quantity
- **Role-Based Access Control**: Clear admin permissions with signature validation
- **Security-First Design**: Implements all security best practices from the reference guide

## Architecture

### Validator Structure

```aiken
validator(admin_pkh: ByteArray) {
  mint(redeemer: Action, context: ScriptContext) -> Bool
}
```

The validator is parameterized with the admin's public key hash, ensuring only the designated administrator can mint new tokens.

### Action Types

```aiken
type Action {
  Mint { amount: Int }  // Positive amount for minting
  Burn { amount: Int }  // Negative amount for burning
}
```

## Admin Setup

### Initial Configuration
The contract requires an admin public key hash to be set during deployment:

```aiken
// Deploy with admin public key hash
let admin_pkh = #"your_admin_public_key_hash_here"
let validator = fungible_token_validator(admin_pkh)
```

### Admin Requirements
- **Public Key Hash**: Must be a valid Cardano public key hash
- **Signature Validation**: Admin must sign all minting transactions
- **Access Control**: Only the designated admin can mint new tokens

## Security Model

### Access Control
- **Minting**: Requires admin signature validation
- **Burning**: Unrestricted (ledger ensures token ownership)
- **Amount Validation**: Positive amounts for minting, negative for burning

### Security Checks
1. **Admin Signature Validation**: Verifies admin signature in transaction
2. **Positive Mint Validation**: Ensures only positive amounts are minted
3. **Burn Logic Validation**: Ensures negative amounts for burning
4. **No Unauthorized Minting**: Only admin can create new tokens

## Usage Examples

### Running Tests

```bash
# Check the project
aiken check

# Run tests with performance metrics
aiken check --trace-level verbose

# Build the project
aiken build
```

### Admin Minting Tokens

```aiken
// Admin mints 1000 tokens
let redeemer = Mint { amount: 1000 }
let context = script_context_with_admin_signature(admin_pkh)
let success = mint(redeemer, admin_pkh, context)
```

### User Burning Tokens

```aiken
// User burns 500 tokens (negative amount)
let redeemer = Burn { amount: -500 }
let context = script_context_with_user_signature(user_pkh)
let success = mint(redeemer, admin_pkh, context)
```

## Testing Strategy

### Test Coverage
- **Success Cases**: Valid admin minting and user burning
- **Failure Cases**: Unauthorized minting, invalid amounts
- **Property Tests**: Admin control invariants
- **Performance Tests**: Large token amount operations

### Test Categories
1. **Unit Tests**: Individual function validation
2. **Integration Tests**: End-to-end token operations
3. **Property Tests**: Security invariant verification
4. **Benchmark Tests**: Performance measurement

## Development Guidelines

### Code Quality Standards
- Custom `Action` type for redeemer
- Modular helper functions for validation
- Comprehensive error handling
- Clear naming conventions
- Extensive test coverage

### Security Checklist
- [x] Admin signature properly validated
- [x] Mint amounts restricted to positive values
- [x] Burn amounts properly handled as negative values
- [x] No unauthorized token creation possible
- [x] Comprehensive test coverage including property tests
- [x] Performance within reasonable limits

## Integration Notes

### Off-Chain Integration
This contract is designed for integration with:
- **Lucid**: JavaScript/TypeScript wallet integration
- **Mesh**: React-based wallet integration
- **Custom Wallets**: Any Cardano-compatible wallet

### Deployment Considerations
- **Testnet Testing**: Always test on testnet first
- **Admin Key Security**: Secure admin private key storage
- **Monitoring**: Track minting and burning operations
- **Backup**: Maintain admin key backups

## Performance Characteristics

### Operation Costs
- **Minting**: O(1) complexity for amount validation
- **Burning**: O(1) complexity for amount validation
- **Signature Verification**: O(n) where n is number of signatories

### Optimization Features
- Efficient amount validation
- Minimal on-chain computation
- Optimized asset calculation

## Related Documentation

- [Token Minting Patterns](../../docs/patterns/token-minting.md)
- [Security Validator Risks](../../docs/security/validator-risks.md)
- [Testing Guidelines](../../docs/language/testing.md)
- [Performance Optimization](../../docs/performance/optimization.md)

## Contributing

When contributing to this contract:
1. Follow the established patterns and conventions
2. Add comprehensive tests for new features
3. Update documentation for any changes
4. Ensure security considerations are addressed
5. Run performance benchmarks for optimizations

## License

Apache-2.0 License - See LICENSE file for details.
