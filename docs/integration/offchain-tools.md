# Off-chain Tools and Integration

## Overview

Aiken is used exclusively for on-chain logic. To build a complete dApp, you need off-chain tools and libraries to construct transactions, interact with wallets, and query the blockchain. This guide provides practical examples for the most popular off-chain libraries.

## Key Concepts

- **Transaction Building**: The process of assembling inputs, outputs, datums, and redeemers off-chain before submitting to the network.
- **Blueprint (`plutus.json`)**: An Aiken-generated file containing the compiled validator scripts (`cborHex`) and their hashes, essential for off-chain tools.
- **Serialization Libraries**: Tools that convert human-readable transaction data into the binary format required by the Cardano network.
- **Wallet Integration**: Connecting the dApp to browser-based or hardware wallets for signing transactions.

## Lucid (TypeScript/JavaScript)

Lucid is a popular library for creating Cardano transactions in JavaScript, Deno, and Node.js environments.

### Code Example

```typescript
import { Blockfrost, Lucid, SpendingValidator, TxHash, Data, UTxO } from "lucid-cardano";
import * as fs from "fs";

// Initialize Lucid
const lucid = await Lucid.new(
  new Blockfrost("https://cardano-preview.blockfrost.io/api/v0", "YOUR_API_KEY"),
  "Preview",
);

// Assume a wallet is selected
lucid.selectWalletFromPrivateKey("YOUR_PRIVATE_KEY");

// Function to read the validator from the Aiken blueprint
const readValidator = (): SpendingValidator => {
  const blueprint = JSON.parse(fs.readFileSync("plutus.json", "utf8"));
  const validator = blueprint.validators;
  return {
    type: "PlutusV2",
    script: validator.compiledCode,
  };
};

const validator = readValidator();
const contractAddress = lucid.utils.validatorToAddress(validator);

// Lock funds in the contract
async function lockFunds(amount: bigint, datum: Data): Promise<TxHash> {
  const tx = await lucid
    .newTx()
    .payToContract(contractAddress, { inline: datum }, { lovelace: amount })
    .complete();

  const signedTx = await tx.sign().complete();
  return signedTx.submit();
}

// Unlock funds from the contract
async function unlockFunds(utxo: UTxO, redeemer: Data): Promise<TxHash> {
  const tx = await lucid
    .newTx()
    .collectFrom([utxo], redeemer)
    .attachSpendingValidator(validator)
    .complete();

  const signedTx = await tx.sign().complete();
  return signedTx.submit();
}
```

## Mesh (React/TypeScript)

Mesh is a comprehensive toolkit for building dApps on Cardano, with strong support for React components.

### Code Example

```typescript
import { MeshTxBuilder, resolveScriptHash } from '@meshsdk/core';
import { useWallet, CardanoWallet } from '@meshsdk/react';
import blueprint from './plutus.json'; // Import the blueprint

function AikenDAppComponent() {
  const { connected, wallet } = useWallet();

  const lockFunds = async () => {
    if (!connected) return;

    const script = {
      code: blueprint.validators.compiledCode,
      version: 'V2',
    };
    const scriptAddress = resolveScriptHash(script.code, 'V2');

    const txBuilder = new MeshTxBuilder({});

    const unsignedTx = await txBuilder
      .txOut(scriptAddress, [{ unit: 'lovelace', quantity: '10000000' }])
      .txOutInlineDatumValue({ owner: '...', amount: 10000000 })
      .changeAddress(await wallet.getChangeAddress())
      .selectUtxosFrom(await wallet.getUtxos())
      .complete();

    const signedTx = await wallet.signTx(unsignedTx);
    const txHash = await wallet.submitTx(signedTx);
    return txHash;
  };

  return (
    <div>
      <CardanoWallet />
      {connected && <button onClick={lockFunds}>Lock 10 ADA</button>}
    </div>
  );
}
```

## PyCardano (Python)

PyCardano is a powerful Python library for creating and signing transactions without external dependencies like `cardano-cli`.

### Code Example

```python
from pycardano import *
import cbor2
import json

# Setup chain context (e.g., with Blockfrost)
context = BlockFrostChainContext("YOUR_API_KEY", base_url=ApiUrls.preview.value)

# Load wallet
payment_skey = PaymentSigningKey.load("payment.skey")
payment_vkey = PaymentVerificationKey.from_signing_key(payment_skey)
my_address = Address(payment_vkey.hash(), network=Network.TESTNET)

# Load Aiken validator from blueprint
with open("plutus.json", "r") as f:
    validator_hex = json.load(f)["validators"]["compiledCode"]
validator_script = PlutusV2Script(bytes.fromhex(validator_hex))
script_address = Address(plutus_script_hash(validator_script), network=Network.TESTNET)

# Lock funds
builder = TransactionBuilder(context)
builder.add_input_address(my_address)
datum = PlutusData.from_dict({"owner": my_address.payment_part.to_primitive()})
builder.add_output(
    TransactionOutput(script_address, amount=10000000, datum=datum)
)

signed_tx = builder.build_and_sign([payment_skey], change_address=my_address)
context.submit_tx(signed_tx.to_cbor())
```

## Related Topics

- [Deployment](./deployment.md)
- [Monitoring](./monitoring.md)
- [Offchain-Onchain Separation](../security/offchain-onchain.md)

## References

- [Lucid Documentation](https://lucid.spacebudz.io/)
- [Mesh SDK Documentation](https://meshjs.dev/)
- [PyCardano Documentation](https://pycardano.readthedocs.io/)
