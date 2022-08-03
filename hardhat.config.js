require("@nomiclabs/hardhat-waffle");
require("hardhat-deploy");
require("dotenv").config();

module.exports = {
    solidity: "0.8.15",
    networks: {
        hardhat: {
            chainId: 31337,
        },
        rinkeby: {
            chainId: 4,
            url: process.env.RINKEBY_RPC_URL,
            accounts: [process.env.PRIVATE_KEY],
        },
    },
    namedAccounts: {
        deployer: {
            default: 0,
        },
    },
};
