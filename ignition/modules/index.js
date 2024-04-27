const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const deployAssetNexusTokenModule = buildModule("AssetNexusToken", (m) => {
  const assetNexusToken = m.contract("AssetNexusToken");
  return { assetNexusToken };
});

const deployAssetNexusNftModule = buildModule("AssetNexusNft", (m) => {
  const assetNexusNft = m.contract("AssetNexusNft");
  return { assetNexusNft };
});

const deployNFTMarketPlaceModule = buildModule("NFTMarketPlace", (m) => {
  const { assetNexusToken } = m.useModule(deployAssetNexusTokenModule);
  const { assetNexusNft } = m.useModule(deployAssetNexusNftModule);


  const nftMarketPlace = m.contract("NFTMarketPlace", [assetNexusToken, assetNexusNft]);

  return { nftMarketPlace };
});

module.exports = deployNFTMarketPlaceModule;