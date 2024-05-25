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
      accounts: [process.env.WALLET_PRIVATE_KEY],
    },
    bnb_mainnet: {
      url: "https://bsc-mainnet.core.chainstack.com/dd54dfb1762a8be07df7e39ce924c4bc",
      chainId: 56,
      accounts: [process.env.WALLET_PRIVATE_KEY],
    },
    sepolia: {
      url: "https://sepolia.infura.io/v3/6b7f3960da564093ade725a5b8e6d3b4",
      accounts: [process.env.WALLET_PRIVATE_KEY], 
    },
    wemix_test: {
      url: "https://api.test.wemix.com",
      accounts: [process.env.WALLET_PRIVATE_KEY]
    }
  },
  etherscan: {
    // https://bscscan.com/myapikey
    apiKey: process.env.BNB_TESTNETSCAN_API_KEY
    // apiKey: process.env.WEMIX_TEST_APIKEY
    // apiKey: process.env.SEPOLIA_TESTNETSCAN_API_KEY
  }

};
