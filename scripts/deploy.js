const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  const balance = await ethers.provider.getBalance(deployer.address);

  console.log("Deploying contracts with the account:", deployer.address);

  // 打印账户余额
  console.log("Account balance:", ethers.formatEther(balance));

  // 部署合约
//   const assetNexusToken = await ethers.deployContract("AssetNexusToken");
//   console.log("AssetNexusToken deployed to:", assetNexusToken.target);

  // 部署 NFTMarketPlace 合约，传入 AssetNexusToken 地址
  const nftMarketPlace = await ethers.deployContract("NFTMarketPlace", [
    "0x6b72efbD2cC99863d747f38B5E158090bA6248b4",
  ]);

  console.log("NFTMarketPlace deployed to:", nftMarketPlace.target);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
