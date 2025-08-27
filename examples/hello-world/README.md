# Hello World Example

[![CI/CD Pipeline](https://github.com/Jimmyh-world/Aiken-ref-guide/workflows/CI/CD%20Pipeline/badge.svg)](https://github.com/Jimmyh-world/Aiken-ref-guide/actions)

This is a simple example project demonstrating a basic Aiken smart contract.

## Version Compatibility

- **Aiken Version**: v1.8.0+
- **Status**: ✅ Tested and validated
- **Last Tested**: August 2024

## Project Structure

```
hello-world/
├── aiken.toml         # Project configuration
├── validators/        # Smart contract logic
│   └── hello_world.ak
├── lib/               # Library modules
│   └── hello_world/
│       └── hello_world_test.ak
└── README.md
```

## Getting Started

1. **Install Aiken**: Follow the installation guide in the main documentation.

2. **Create the project**:
   ```bash
   aiken new my-user/hello-world
   cd hello-world
   ```

3. **Add the validator code** to `validators/hello_world.ak`:
   ```aiken
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
   ```

4. **Add tests** to `lib/hello_world/hello_world_test.ak`:
   ```aiken
   use aiken/list
   use hello_world/hello_world.{spend}

   test spend_succeeds() {
     let owner_key = #"00010203"
     let datum = Datum { owner: owner_key }
     let redeemer = "Hello, World!"
     let context = mock_context([owner_key])
     
     spend(datum, redeemer, context)
   }
   ```

5. **Run the tests**:
   ```bash
   aiken check
   ```

6. **Build the project**:
   ```bash
   aiken build
   ```

## What This Contract Does

This simple validator demonstrates:
- **Datum**: Stores the owner's public key hash
- **Redeemer**: Must contain the exact message "Hello, World!"
- **Validation**: Requires both the correct message AND the owner's signature

The contract will only allow spending if both conditions are met.

## Next Steps

- Try modifying the redeemer message to see the test fail
- Add more test cases for different scenarios
- Explore the other examples in the documentation
