## Deployment Verification Process (Hardhat Official Website Tutorial)
1. compile `npx hardhat compile`
2. deploy `npx hardhat ignition deploy ./ignition/modules/Lock.js --network bnb_testnet`
2. verify `npx hardhat verify --network bnb_testnet ${contratc_address}  ${constructor_args}`
## Reference document
- bnb doc：https://docs.bnbchain.org/docs/hardhat-new/#compile-smart-contract
- hardhat doc：https://hardhat.org/hardhat-runner/docs/guides/deploying
- bnb_test：[https://bscscan.com/](https://testnet.bscscan.com/)
## Deploy information
Deployed Addresses

AssetNexusNft#AssetNexusNft - 0x07257f26590C08be6fAE45326397DC2258A9B4A1
AssetNexusToken#AssetNexusToken - 0x086edea0BbAc369dCa0B2E5bf967085A76975498
NFTMarketPlace#NFTMarketPlace - 0x50E8B428cFe4daaBA8d1c3085d3Da9f901c8165f


# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.js
```
