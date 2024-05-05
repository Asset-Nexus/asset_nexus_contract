## Deployment Verification Process (Hardhat Official Website Tutorial)
1. compile `npx hardhat compile`
2. test `npx hardhat test --network hardhat`
3. deploy `npx hardhat ignition deploy ./ignition/modules/index.js --network bnb_testnet`
4. verify `npx hardhat verify --network bnb_testnet ${contratc_address}  ${constructor_args}`
## Reference document
- bnb doc：https://docs.bnbchain.org/docs/hardhat-new/#compile-smart-contract
- hardhat doc：https://hardhat.org/hardhat-runner/docs/guides/deploying
- bnb_test：https://testnet.bscscan.com/
## Deploy information
bsc testnet:
AssetNexusNft#AssetNexusNft - 0xeC8aCa83fa696c57e58218e0F38698787c217320
AssetNexusToken#AssetNexusToken - 0x9D964d0e4Ae80Eb798088a998af1a36DC4A0DE49
NFTMarketPlace#NFTMarketPlace - 0xF393253cDbfbd7c147A35928e874016c873Fb723

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
