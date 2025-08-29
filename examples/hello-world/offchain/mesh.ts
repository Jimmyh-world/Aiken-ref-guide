// Hello World Validator - Mesh Integration
// Complete TypeScript implementation for interacting with the Hello World validator

import { MeshTxBuilder, MeshWallet, BlockfrostProvider } from '@meshsdk/core';
import * as dotenv from 'dotenv';

dotenv.config();

export class HelloWorldMesh {
  private wallet: MeshWallet;
  private txBuilder: MeshTxBuilder;

  constructor(wallet: MeshWallet) {
    this.wallet = wallet;
    this.txBuilder = new MeshTxBuilder(wallet);
  }

  async lock(amountLovelace: string, ownerPubKeyHash: string): Promise<string> {
    try {
      // Create datum with owner public key hash
      const datum = {
        owner: ownerPubKeyHash,
      };

      // Build transaction to lock ADA to validator
      const tx = await this.txBuilder
        .sendLovelace(
          process.env.HELLO_WORLD_SCRIPT_ADDRESS!,
          amountLovelace,
          datum
        )
        .complete();

      return tx;
    } catch (error) {
      console.error('Error locking ADA:', error);
      throw error;
    }
  }

  async unlock(scriptUtxo: any): Promise<string> {
    try {
      // Create redeemer with "Hello, World!" message
      const redeemer = {
        message: 'Hello, World!',
      };

      // Build transaction to unlock ADA from validator
      const tx = await this.txBuilder
        .spendPlutusScriptUtxo(scriptUtxo, redeemer)
        .complete();

      return tx;
    } catch (error) {
      console.error('Error unlocking ADA:', error);
      throw error;
    }
  }

  async getScriptUtxos(): Promise<any[]> {
    try {
      const utxos = await this.wallet.getUtxos();
      return utxos.filter(
        (utxo) => utxo.output.address === process.env.HELLO_WORLD_SCRIPT_ADDRESS
      );
    } catch (error) {
      console.error('Error getting script UTxOs:', error);
      throw error;
    }
  }
}

// CLI Interface
async function main() {
  const [command, ...args] = process.argv.slice(2);

  if (!process.env.HELLO_WORLD_SCRIPT_ADDRESS) {
    console.error('HELLO_WORLD_SCRIPT_ADDRESS environment variable required');
    process.exit(1);
  }

  try {
    const wallet = new MeshWallet();
    const helloWorld = new HelloWorldMesh(wallet);

    switch (command) {
      case 'lock':
        const amount = args[0] || '10000000'; // 10 ADA default
        const ownerPkh = args[1] || process.env.OWNER_PUBKEY_HASH;
        if (!ownerPkh) {
          console.error('Owner public key hash required');
          process.exit(1);
        }
        const lockTx = await helloWorld.lock(amount, ownerPkh);
        console.log('Lock transaction:', lockTx);
        break;

      case 'unlock':
        const utxos = await helloWorld.getScriptUtxos();
        if (utxos.length === 0) {
          console.error('No UTxOs found at script address');
          process.exit(1);
        }
        const unlockTx = await helloWorld.unlock(utxos[0]);
        console.log('Unlock transaction:', unlockTx);
        break;

      case 'utxos':
        const scriptUtxos = await helloWorld.getScriptUtxos();
        console.log('Script UTxOs:', scriptUtxos);
        break;

      default:
        console.log('Usage:');
        console.log('  npm run lock [amount] [owner_pkh]');
        console.log('  npm run unlock');
        console.log('  ts-node mesh.ts utxos');
        break;
    }
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

if (require.main === module) {
  main();
}
