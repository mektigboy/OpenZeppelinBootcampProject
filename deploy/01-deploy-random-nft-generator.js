const { network, ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const chainId = network.config.chainId;

    let vrfCoordinatorV2Address, subscriptionId;

    const FUND_AMOUNT = "10000000000000000000"; // 1e19

    let tokenUris = [
        "ipfs://bafkreidiszt2rp5unghfq3xfdagqcl7b6z2yc4ef6bmkbqbrqrcvoahnby", // 1
        "ipfs://bafkreiaulh6ope6bamhyhlzgwisc3djffjuclt5zxxamsypmqrulb3kkqa", // 2
        "ipfs://bafkreiayes7ej5kzziio3fydpjjtdygtaxckjitka5z6txfgqgkfeticaq", // 3
    ];

    if (chainId == 31337) {
        const vrfCoordinatorV2Mock = await ethers.getContract(
            "VRFCoordinatorV2Mock"
        );
        vrfCoordinatorV2Address = vrfCoordinatorV2Mock.address;
        const tx = await vrfCoordinatorV2Mock.createSubscription();
        const txReceipt = await tx.wait(1);
        subscriptionId = txReceipt.events[0].args.subId;
        await vrfCoordinatorV2Mock.fundSubscription(
            subscriptionId,
            FUND_AMOUNT
        );
    } else {
        // Rinkeby
        vrfCoordinatorV2Address = "0x6168499c0cFfCaCD319c818142124B7A15E857ab";
        subscriptionId = "9747";
    }

    args = [
        vrfCoordinatorV2Address,
        "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc", // gasLane
        subscriptionId,
        "500000", // callbackGasLimit
        tokenUris,
    ];

    const random = await deploy("Random", {
        from: deployer,
        log: true,
        args: args,
    });

    console.log(random.address);
};

module.exports.tags = ["all", "random-nft-generator"];
