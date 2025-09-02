# Escrow Contract Deployment Checklist

## Prerequisites
- [ ] Buyer wallet funded with testnet ADA (minimum 50.17 ADA)
- [ ] Seller wallet created and funded with minimum ADA
- [ ] Blockfrost API key configured
- [ ] cardano-cli or PyCardano environment set up

## Deployment Steps
- [ ] Generate script address from validator hash
- [ ] Create datum with real buyer/seller addresses
- [ ] Submit lock transaction from buyer wallet
- [ ] Verify UTxO created at script address
- [ ] Test completion workflow
- [ ] Test refund workflow (optional)

## Success Criteria
- [ ] Funds successfully locked in escrow
- [ ] Completion transaction releases funds to seller
- [ ] Refund transaction returns funds to buyer
- [ ] All transaction costs within expected range

## Contract Details
- Validator Hash: 76b1f73d1374791ea1ac5106ae09b1d1955fe0df8ff4ea0c5b99e951
- Network: preprod testnet
- Script Address: addr_test1w9m37uax9ax7829pkxgbp4w8mn6ev8nwu0nrvl8vfjkn29qlcrgzv
- Estimated Costs: Lock ~172891, Complete ~175181, Refund ~175181 lovelace
