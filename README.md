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
AssetNexusNft#AssetNexusNft - 0xD0e1e02AaBfC1DA1381519aB97167CaE9ce979ae
AssetNexusToken#AssetNexusToken - 0xc5357b5424ED35C9e3d6DA958BeDcCc172e4Fde5
NFTMarketPlace#NFTMarketPlace - 0x10f9227D860B4dE05f873DF74A1246c272C454b3

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
