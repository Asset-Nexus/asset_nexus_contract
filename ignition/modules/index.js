const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

// const deployAssetNexusTokenModule = buildModule("AssetNexusToken", (m) => {
//   const assetNexusToken = m.contract("AssetNexusToken");
//   return { assetNexusToken };
// });


// const deployAssetNexusNftModule = buildModule("AssetNexusNft", (m) => {
//   const assetNexusNft = m.contract("AssetNexusNft", ["MyArtCollection", "ARTC"]);
//   return { assetNexusNft };
// });

const deployNFTMarketPlaceModule = buildModule("NFTMarketPlace", (m) => {
  // const { assetNexusToken } = m.useModule(deployAssetNexusTokenModule);
  // const { assetNexusNft } = m.useModule(deployAssetNexusNftModule);
  const nftMarketPlace = m.contract("NFTMarketPlace", ["0x9D964d0e4Ae80Eb798088a998af1a36DC4A0DE49"]);
  return { nftMarketPlace };
});

module.exports = deployNFTMarketPlaceModule;