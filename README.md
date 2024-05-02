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
Deployed Addresses

AssetNexusNft#AssetNexusNft - 
AssetNexusToken#AssetNexusToken - 0x7e7fc807C8f232d249D03870f60EcCa0f90Dd723
NFTMarketPlace#NFTMarketPlace - 0xBC9eF51F02fCf3AB20fc01c4846e187F53cE08C3

sepolia:
AssetNexusToken#AssetNexusToken - 0x1E3aEb8146C4Cc9fe263A16f8Ff88b2e8B1584b9
NFTMarketPlace#NFTMarketPlace - 0xfcaEE18ca3595a47a0b354E2ca6D6284A2d970f6


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
