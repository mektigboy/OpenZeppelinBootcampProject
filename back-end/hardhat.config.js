require("dotenv").config();
require("hardhat-deploy");
require("hardhat-gas-reporter");
require("solidity-coverage");
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");

const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY || "";
const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY || "";
const PRIVATE_KEY = process.env.PRIVATE_KEY || "";
const RINKEBY_RPC_URL = process.env.RINKEBY_RPC_URL || "";

module.exports = {
    defaultNetwork: "hardhat",
    etherscan: {
        apiKey: ETHERSCAN_API_KEY,
    },
    gasReporter: {
        enabled: true,
        coinmarketcap: COINMARKETCAP_API_KEY,
        currency: "USD",
        noColors: true,
        outputFile: "gas-report.txt",
        token: "ETH",
    },
    mocha: {
        timeout: 200000, // 200 sec.
    },
    namedAccounts: {
        deployer: {
            default: 0,
            1: 0,
        },
    },
    networks: {
        hardhat: {
            chainId: 31337,
            // gasPrice: 130000000000,
        },
        rinkeby: {
            accounts: [PRIVATE_KEY],
            blockConfirmations: 6,
            chainId: 4,
            url: RINKEBY_RPC_URL,
        },
    },
    solidity: {
        compilers: [
            {
                version: "0.8.15",
            },
        ],
    },
};
