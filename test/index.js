const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Test", function () {
  let accountA, accountB, accountC, accountD;
  let assetNexusToken, assetNexusNft, nftMarketPlace;
  const fashion_uri =
    "https://ipfs.filebase.io/ipfs/QmTz6ajnLUXwaXCjZ7Zvdk2nXGdQNspnLPsgwZFDP45tUJ/fashion.json";
  const ghost_uri =
    "https://ipfs.filebase.io/ipfs/QmTz6ajnLUXwaXCjZ7Zvdk2nXGdQNspnLPsgwZFDP45tUJ/ghost.json";
  const godfather_uri =
    "https://ipfs.filebase.io/ipfs/QmTz6ajnLUXwaXCjZ7Zvdk2nXGdQNspnLPsgwZFDP45tUJ/godfather.json";
  const smoke_uri =
    "https://ipfs.filebase.io/ipfs/QmTz6ajnLUXwaXCjZ7Zvdk2nXGdQNspnLPsgwZFDP45tUJ/smoke.json";

  this.beforeEach(async function () {
    [accountA, accountB, accountC, accountD] = await ethers.getSigners();

    assetNexusToken = await ethers.deployContract(
      "AssetNexusToken",
      [],
      accountA
    );

    messenger = await ethers.deployContract(
      "Messenger",
      ["0xA8C0c11bf64AF62CDCA6f93D3769B88BdD7cb93D", "0x3580c7A817cCD41f7e02143BFa411D4EeAE78093"],
      accountA
    );

    nftMarketPlace = await ethers.deployContract(
      "NFTMarketPlace",
      [assetNexusToken.target],
      accountA
    );

    await nftMarketPlace.addAddressToWhitelist(accountA.address);
    await nftMarketPlace.createAssetNexusNft("asset_nxus", "an");

    let assetNexusNftAddr = await nftMarketPlace.nftContractsByNames(
      "asset_nxus"
    );
    console.log("assetNexusNftAddr: ", assetNexusNftAddr);
    assetNexusNft = await ethers.getContractAt(
      "AssetNexusNft",
      assetNexusNftAddr
    );

    console.log("assetNexusToken: ", assetNexusToken.target);
    console.log("assetNexusNft: ", assetNexusNft.target);
    console.log("nftMarketPlace: ", nftMarketPlace.target);

    // Cast 100 tokens per account
    let mintAmount = ethers.parseEther("100");
    await assetNexusToken.mint(accountA.address, mintAmount);
    await assetNexusToken.mint(accountB.address, mintAmount);
    await assetNexusToken.mint(accountC.address, mintAmount);
    await assetNexusToken.mint(accountD.address, mintAmount);
    // Cast one NFT for each account
    await assetNexusNft.connect(accountA).mintItem(fashion_uri);
    await assetNexusNft.connect(accountB).mintItem(ghost_uri);
    await assetNexusNft.connect(accountC).mintItem(godfather_uri);
    await assetNexusNft.connect(accountD).mintItem(smoke_uri);

    // token approve
    await assetNexusToken
      .connect(accountA)
      .approve(nftMarketPlace.target, ethers.parseEther("100"));
    await assetNexusToken
      .connect(accountB)
      .approve(nftMarketPlace.target, ethers.parseEther("100"));
    await assetNexusToken
      .connect(accountC)
      .approve(nftMarketPlace.target, ethers.parseEther("100"));
    await assetNexusToken
      .connect(accountD)
      .approve(nftMarketPlace.target, ethers.parseEther("100"));
    // nft approve
    await assetNexusNft.connect(accountA).approve(nftMarketPlace.target, 0n);
    await assetNexusNft.connect(accountB).approve(nftMarketPlace.target, 1n);
    await assetNexusNft.connect(accountC).approve(nftMarketPlace.target, 2n);
    await assetNexusNft.connect(accountD).approve(nftMarketPlace.target, 3n);
  });

  it("token uri", async function () {
    let uri = await assetNexusNft.connect(accountA).tokenURI(0n);
    console.log("uri: ", uri);
  });

  it("display function", async function () {
    //  address nftAddr,
    // uint256 tokenId,
    // uint256 price,
    // uint chainId,
    // bool isCrossChain
    await nftMarketPlace
      .connect(accountA)
      .listItem(assetNexusNft.target, 0n, ethers.parseEther("8"), "97", false);
    let listingInfo = await nftMarketPlace.nftListings(
      assetNexusNft.target,
      0n
    );
    console.log("listingInfo: ", listingInfo);

    let accountAListingInfo = await nftMarketPlace.getMyListing(
      accountA.address
    );
    console.log("accountAListingInfo: ", accountAListingInfo);

    let allListing = await nftMarketPlace.getAllListing();
    console.log("allListing: ", allListing);

    let newOwner = await assetNexusNft.ownerOf(0n);
    expect(newOwner).to.equal(nftMarketPlace.target);
  });

  // A nftListings, B buy
  it("buy function", async function () {
    await nftMarketPlace
      .connect(accountA)
      .listItem(assetNexusNft.target, 0n, ethers.parseEther("8"), "97", false);
      //address nftAddr,
      // uint256 tokenId,
      // uint64 destinationChainSelector,
      // address receiver,
      // bool isCrossChain
    await nftMarketPlace.connect(accountB).buyItem(assetNexusNft.target, 0n, 0n, accountA.address, false);
    let newOwner = await assetNexusNft.ownerOf(0n);
    expect(newOwner).to.equal(accountB.address);

    let marketBalance = await assetNexusToken.balanceOf(nftMarketPlace.target);
    let accountBBalance = await assetNexusToken.balanceOf(accountB.address);
    let accountAProcess = await nftMarketPlace.proceeds(accountA.address);

    expect(marketBalance).to.equal(ethers.parseEther("8"));
    expect(accountBBalance).to.equal(ethers.parseEther("92"));
    expect(accountAProcess).to.equal(ethers.parseEther("8"));

    // A withdraw
    await nftMarketPlace.connect(accountA).withDrawProceeds();
    let newAccountAProcess = await nftMarketPlace.proceeds(accountA.address);
    expect(newAccountAProcess).to.equal(ethers.parseEther("0"));
    let accountABalance = await assetNexusToken.balanceOf(accountA.address);
    expect(accountABalance).to.equal(ethers.parseEther("108"));
  });

  // A nftListings, A cancel
  it("cancel function", async function () {
    await nftMarketPlace
      .connect(accountA)
      .listItem(assetNexusNft.target, 0n, ethers.parseEther("8"), "97", false);
    let newOwner = await assetNexusNft.ownerOf(0n);
    expect(newOwner).to.equal(nftMarketPlace.target);
    let listingInfo = await nftMarketPlace.nftListings(
      assetNexusNft.target,
      0n
    );
    console.log("listingInfo: ", listingInfo);

    await nftMarketPlace
      .connect(accountA)
      .cancelListing(assetNexusNft.target, 0n);
    let afterNewOwner = await assetNexusNft.ownerOf(0n);
    expect(afterNewOwner).to.equal(accountA.address);
    let afterListingInfo = await nftMarketPlace.nftListings(
      assetNexusNft.target,
      0n
    );
    console.log("afterListingInfo: ", afterListingInfo);
  });

  // A nftListings, A update
  it("update function", async function () {
    await nftMarketPlace
      .connect(accountA)
      .listItem(assetNexusNft.target, 0n, ethers.parseEther("8"), "97", false);
    await nftMarketPlace
      .connect(accountA)
      .updateListing(assetNexusNft.target, 0n, ethers.parseEther("5"));
    let listingInfo = await nftMarketPlace.nftListings(
      assetNexusNft.target,
      0n
    );
    console.log("listingInfo: ", listingInfo);
  });

  // whitelist
  it("whiteList function", async function () {
    await nftMarketPlace.addAddressToWhitelist(accountB.address);
    let isWhite = await nftMarketPlace.whitelist(accountB.address);
    expect(isWhite).to.equal(true);
  });
});
