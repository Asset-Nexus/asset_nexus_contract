## Deployment Verification Process (Hardhat Official Website Tutorial)
1. compile `npx hardhat compile`
2. test `npx hardhat test --network hardhat`
3. deploy `npx hardhat ignition deploy ${path} --network ${network}`
4. verify `npx hardhat verify --network bnb_testnet ${contratc_address}  ${constructor_args}`
## Reference document
- bnb doc：https://docs.bnbchain.org/docs/hardhat-new/#compile-smart-contract
- hardhat doc：https://hardhat.org/hardhat-runner/docs/guides/deploying
- bnb_test：https://testnet.bscscan.com/
## Deploy information
bsc testnet:
NFTMarketPlace#AssetNexusNft - 0x07bCeBAAE91C26dF232301eA292fcD0D49Efb04A
NFTMarketPlace#AssetNexusToken - 0xFCE8d1a831cDCb085897825C4674B137a17bA2ed
NFTMarketPlace#Messenger - 0xBcDD9f7835d0994Bde8bA1D24ffC2AF0cbBdF64e
NFTMarketPlace#NFTMarketPlace - 0xBFbEf835f24CC8C54b407fa6790eF3242e787ED8

wemix:
> Due to the fact that hardhat does not support deployment and verification of the network, it is temporarily executed through the remix ide.
nft：0xB6cBBbbF49664c749Fc519d7d03194C22645CC31
receiver：0xD6C1e806B29D22B862e5c8AA2a35CE2e98B82002

## Test account
1. 0xc0ee714715108b1a6795391f7e05a044d795ba70
secret key: 641943fa6c3fab18fed274c2b3194f0d71383ecfb9a58b2d70188e693c245510
2. 0xb9d47c289b8dacff0b894e385464f51e5eabdd86
secret key: a39de0eaa34cd3be35a7a200989437b9f672a4056298a51f086db9b634683fec

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
