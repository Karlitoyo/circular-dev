const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-toolbox/network-helpers");


describe("ProductPassport", function () {
  let ProductPassport;
  let productPassportBottle;
  let productPassportBottleCap;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    ProductPassport = await ethers.getContractFactory("ProductPassport");
    productPassportBottle = await ProductPassport.deploy("Clothing Item XYZ", "XYZ", "https://raw.githubusercontent.com/Karlitoyo/Shihverse-Nft-Marketpace-Next/main/content/meta.json", []);
    productPassportBottleCap = await ProductPassport.deploy("BottleCap", "BCAP", "https://raw.githubusercontent.com/Karlitoyo/Shihverse-Nft-Marketpace-Next/main/content/meta.json", []);
    await productPassportBottle.waitForDeployment();
    await productPassportBottleCap.waitForDeployment();
  });

  it("Should set base URI", async function () {
    const newBaseURI = "NewBaseURI";
    await productPassportBottle.setBaseURI(newBaseURI);
    const baseURI = await productPassportBottle.getBaseURL();

    expect(baseURI).to.equal(newBaseURI);
  });

  it("Should get components", async function () {
    const  componentAddress = [];
    const anotherComponentContract = await ProductPassport.deploy(
      "Electronic Device ABC", 
      "ABC", 
      "https://raw.githubusercontent.com/Karlitoyo/Shihverse-Nft-Marketpace-Next/main/content/meta.json", 
      componentAddress);
    await anotherComponentContract.waitForDeployment();
    const components = await productPassportBottle.getComponents();
    console.log(components);

    expect(components);
  });

  it("Should get URL", async function () {
    const  componentAddress = [];
    const anotherComponentContract = await ProductPassport.deploy(
      "Electronic Device ABC", 
      "ABC", 
      "https://raw.githubusercontent.com/Karlitoyo/Shihverse-Nft-Marketpace-Next/main/content/meta.json", 
      componentAddress);
    await anotherComponentContract.waitForDeployment();
    const url = await productPassportBottle.getBaseURL();
    console.log(url);

    expect(url);
  });

});
