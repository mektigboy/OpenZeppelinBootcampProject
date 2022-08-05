const developmentChains = ["hardhat", "localhost"];

const DECIMALS = "18";
const BASE_FEE = "250000000000000000"; // 0.25 LINK
const GAS_PRICE_LINK = 1e9; // 0.000000001 LINK per gas
const INITIAL_PRICE = "200000000000000000000"; // 2e20

const networkConfig = {
    4: {
        vrfCoordinatorV2: "0x6168499c0cFfCaCD319c818142124B7A15E857ab",
        callbackGasLimit: "500000", // 500,000 gas
        ethUsdPriceFeed: "0x8A753747A1Fa494EC906cE90E9f37563A8AF630e",
        gasLane:
            "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",
        mintFee: "10000000000000000", // 0.01 ETH
        name: "rinkeby",
        subscriptionId: "9747",
    },
    31337: {
        callbackGasLimit: "500000", // 500,000 gas
        ethUsdPriceFeed: "0x9326BFA02ADD2366b30bacB125260Af641031331",
        gasLane:
            "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc", // 30 gwei
        mintFee: "10000000000000000", // 0.01 ETH
        name: "localhost",
    },
    // Arbitrum
    // Polygon
};

module.exports = {
    developmentChains,
    DECIMALS,
    BASE_FEE,
    GAS_PRICE_LINK,
    INITIAL_PRICE,
    networkConfig,
};
