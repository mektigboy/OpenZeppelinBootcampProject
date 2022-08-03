const { ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts }) => {
    const { deployer } = await getNamedAccounts();
    const random = await ethers.getContract("RandomNFTGenerator", deployer);
    const mintTx = await random.requestObject();
    const mintTxReceipt = await mintTx.wait(1);
};

module.exports.tags = ["all", "mint"];
