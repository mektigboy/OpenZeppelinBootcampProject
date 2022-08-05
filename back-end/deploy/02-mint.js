const { ethers, network } = require("hardhat");

module.exports = async function ({ getNamedAccounts }) {
    const { deployer } = await getNamedAccounts();
    const chainId = network.config.chainId;

    const abitoRandomNFTGenerator = await ethers.getContract("AbitoRandomNFTGenerator", deployer);
    const mintFee = await abitoRandomNFTGenerator.getMintFee();
    const abitoMintTransaction = await abitoRandomNFTGenerator.mintWhitelist({
        value: mintFee.toString(),
    });
    const abitoMintTransactionReceipt = await abitoMintTransaction.wait(1);

    await new Promise(async function (resolve, reject) {
        setTimeout(
            () => reject("Timeout: event <NFTMinted> did not fire."),
            100000 // 300000 // 5 minutes
        );
        abitoRandomNFTGenerator.once("NFTMinted", async function () {
            resolve();
        });

        if (chainId == 31337) {
            const requestId =
                abitoMintTransactionReceipt.events[1].args.requestId.toString();
            const coordinatorMock = await ethers.getContract(
                "VRFCoordinatorV2Mock",
                deployer
            );
            await coordinatorMock.fulfillRandomWords(
                requestId,
                abitoRandomNFTGenerator.address
            );
        }
    });

    console.log(
        `Random NFT index 0 has token URI: ${await abitoRandomNFTGenerator.tokenURI(0)}`
    );
};

module.exports.tags = ["all", "mint"];
