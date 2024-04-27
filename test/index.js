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

  this.beforeEach(async function () {
    [accountA, accountB, accountC, accountD] = await ethers.getSigners();

    assetNexusToken = await ethers.deployContract(
      "AssetNexusToken",
      [],
      accountA
    );
    assetNexusNft = await ethers.deployContract("AssetNexusNft", [], accountA);

    nftMarketPlace = await ethers.deployContract(
      "NFTMarketPlace",
      [assetNexusToken.target, assetNexusNft.target],
      accountA
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
    await assetNexusNft.connect(accountA).mint();
    await assetNexusNft.connect(accountB).mint();
    await assetNexusNft.connect(accountC).mint();
    await assetNexusNft.connect(accountD).mint();

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

  it("display function", async function () {
    await nftMarketPlace.connect(accountA).listItem(ethers.parseEther("8"), 0n);
    let listingInfo = await nftMarketPlace.listing(assetNexusNft.target, 0n);
    console.log("listingInfo: ", listingInfo);
    let newOwner = await assetNexusNft.ownerOf(0n);
    expect(newOwner).to.equal(nftMarketPlace.target);
  });

  // A listing, B buy
  it("buy function", async function () {
    await nftMarketPlace.connect(accountA).listItem(ethers.parseEther("8"), 0n);
    await nftMarketPlace.connect(accountB).buyItem(0n);
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

  // A listing, A cancel
  it("cancel function", async function () {
    await nftMarketPlace.connect(accountA).listItem(ethers.parseEther("8"), 0n);
    let newOwner = await assetNexusNft.ownerOf(0n);
    expect(newOwner).to.equal(nftMarketPlace.target);
    let listingInfo = await nftMarketPlace.listing(assetNexusNft.target, 0n);
    expect(listingInfo).to.deep.equal([
      ethers.parseEther("8"),
      accountA.address,
    ]);
    await nftMarketPlace.connect(accountA).cancelListing(0n);
    let afterNewOwner = await assetNexusNft.ownerOf(0n);
    expect(afterNewOwner).to.equal(accountA.address);
    let afterListingInfo = await nftMarketPlace.listing(
      assetNexusNft.target,
      0n
    );
    expect(afterListingInfo).to.deep.equal([
      ethers.parseEther("0"),
      "0x0000000000000000000000000000000000000000",
    ]);
  });

  // A listing, A update
  it("cancel function", async function () {
    await nftMarketPlace.connect(accountA).listItem(ethers.parseEther("8"), 0n);
    await nftMarketPlace
      .connect(accountA)
      .updateListing(0n, ethers.parseEther("5"));
    let listingInfo = await nftMarketPlace.listing(assetNexusNft.target, 0n);
    expect(listingInfo).to.deep.equal([
      ethers.parseEther("5"),
      accountA.address,
    ]);
  });
});
