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
      url: "https://bsc-dataseed.bnbchain.org/",
      chainId: 56,
      accounts: [process.env.WALLET_PRIVATE_KEY],
    },
    sepolia: {
      url: "https://sepolia.infura.io/v3/6b7f3960da564093ade725a5b8e6d3b4", // 替换为 Sepolia API 的节点 URL
      accounts: [process.env.WALLET_PRIVATE_KEY], // 设置部署账户的私钥
    }
  },
  etherscan: {
    // https://bscscan.com/myapikey
    apiKey: process.env.BNB_TESTNETSCAN_API_KEY
    // apiKey: process.env.SEPOLIA_TESTNETSCAN_API_KEY
  },
};
