const { ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts }) => {
    const { deployer } = await getNamedAccounts();
    const random = await ethers.getContract("RandomNFTGenerator", deployer);
    const mintTransaction = await random.requestObject();
    const mintTransactionReceipt = await mintTransaction.wait(1);
};

module.exports.tags = ["all", "mint"];
