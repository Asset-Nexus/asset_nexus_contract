const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const deployNFTMarketPlaceModule = buildModule("NFTMarketPlace", (m) => {
  const assetNexusToken = m.contract("AssetNexusToken");
  const assetNexusNft = m.contract("AssetNexusNft", ["AssetNexusNFT", "ANN"]);
  const messenger = m.contract("Messenger", ["0xE1053aE1857476f36A3C62580FF9b016E8EE8F6f", "0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06"]);
  const nftMarketPlace = m.contract("NFTMarketPlace", [assetNexusToken, messenger]);
  return { nftMarketPlace };
});

module.exports = deployNFTMarketPlaceModule;