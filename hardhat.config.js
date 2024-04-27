require("@nomicfoundation/hardhat-toolbox");
const dotenv = require("dotenv");
dotenv.config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  defaultNetwork: "bnb_testnet",
  networks: {
    bnb_testnet: {
      url: "https://data-seed-prebsc-1-s1.bnbchain.org:8545",
      chainId: 97,
      gasPrice: 20000000000,
      accounts:[process.env.WALLET_PRIVATE_KEY]
    },
    bnb_mainnet: {
      url: "https://bsc-dataseed.bnbchain.org/",
      chainId: 56,
      gasPrice: 20000000000,
      accounts:[process.env.WALLET_PRIVATE_KEY]
    }
  },
  etherscan: {
    // https://bscscan.com/myapikey
    apiKey: process.env.BNB_TESTNETSCAN_API_KEY 
  }
};
