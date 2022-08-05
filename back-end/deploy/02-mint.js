const { ethers, network } = require("hardhat");

module.exports = async function ({ getNamedAccounts }) {
    const { deployer } = await getNamedAccounts();
    const chainId = network.config.chainId;

    const randomNFTGenerator = await ethers.getContract("RandomNFTGenerator", deployer);
    const mintFee = await randomNFTGenerator.getMintFee();
    const randomMintTransaction = await randomNFTGenerator.requestNFT({
        value: mintFee.toString(),
    });
    const randomMintTransactionReceipt = await randomMintTransaction.wait(1);

    await new Promise(async function (resolve, reject) {
        setTimeout(
            () => reject("Timeout: event <NFTMinted> did not fire."),
            100000 // 300000 // 5 minutes
        );
        randomNFTGenerator.once("NFTMinted", async function () {
            resolve();
        });

        if (chainId == 31337) {
            const requestId =
                randomMintTransactionReceipt.events[1].args.requestId.toString();
            const coordinatorMock = await ethers.getContract(
                "VRFCoordinatorV2Mock",
                deployer
            );
            await coordinatorMock.fulfillRandomWords(
                requestId,
                randomNFTGenerator.address
            );
        }
    });

    console.log(
        `Random NFT index 0 has token URI: ${await randomNFTGenerator.tokenURI(0)}`
    );
};

module.exports.tags = ["all", "mint"];
