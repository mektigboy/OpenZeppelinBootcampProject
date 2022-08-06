const { network, ethers } = require("hardhat");
const {
    developmentChains,
    networkConfig,
} = require("../helper-hardhat-config");
const { verify } = require("../utils/verify");

module.exports = async function ({ deployments, getNamedAccounts }) {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const chainId = network.config.chainId;

    let coordinatorAddress, subscriptionId;

    const FUND_AMOUNT = "1000000000000000000000";

    const tokenURIs = [
        "ipfs://bafkreia35hmeoi2gbeib7louigapnicybxzhnu3ow7mrzjvjhy2lxh5nwq", // 1
        "ipfs://bafkreiaulh6ope6bamhyhlzgwisc3djffjuclt5zxxamsypmqrulb3kkqa", // 2
        "ipfs://bafkreiayes7ej5kzziio3fydpjjtdygtaxckjitka5z6txfgqgkfeticaq", // 3
    ];

    if (chainId == 31337) {
        const coordinatorMock = await ethers.getContract(
            "VRFCoordinatorV2Mock"
        );
        coordinatorAddress = coordinatorMock.address;
        const transactionResponse = await coordinatorMock.createSubscription();
        const transactionReceipt = await transactionResponse.wait(1);
        subscriptionId = transactionReceipt.events[0].args.subId;
        await coordinatorMock.fundSubscription(subscriptionId, FUND_AMOUNT);
    } else {
        coordinatorAddress = networkConfig[chainId].vrfCoordinatorV2;
        subscriptionId = networkConfig[chainId].subscriptionId;
    }

    log("--------------------------------------------------");

    const arguments = [
        networkConfig[chainId].maxWhitelistedAddresses,
        networkConfig[chainId].maxNFTLimit,
        networkConfig[chainId].maxNFTLimitWhitelist,
        coordinatorAddress,
        subscriptionId,
        networkConfig[chainId].gasLane,
        networkConfig[chainId].callbackGasLimit,
        tokenURIs,
        networkConfig[chainId].mintFee,
    ];

    const abitoRandomNFTGenerator = await deploy("AbitoRandomNFTGenerator", {
        args: arguments,
        from: deployer,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    });

    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        log("Verifying...");
        await verify(abitoRandomNFTGenerator.address, arguments);
    }
};

module.exports.tags = ["abito-random-nft-generator", "all", "main"];
