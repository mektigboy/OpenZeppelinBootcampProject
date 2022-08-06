# OpenZeppelin Bootcamp Project

## Project Description

An application to randomly mint NFTs based on probability using Chainlink VRF V2 and OpenZeppelin libraries.
Each token URI points to the token metadata stored in IPFS.

## Authors

- [antovanFI](https://github.com/antovanFI)
- [Elizao](https://github.com/Elizao)
- [irwingtello](https://github.com/irwingtello)
- [leandrogavidia](https://github.com/leandrogavidia)
- [mektigboy](https://github.com/mektigboy)

## Innovation

We implement a true decentralized and random way to generate data using Chainlink VRF V2.
Also, our contracts use the latest version of Solidity, and the v0.8 OpenZeppelin libraries, which are up-to-date.

## Usage & Installation

1. Clone the repo, and cd into the back-end folder:

```
git clone https://github.com/mektigboy/OpenZeppelinBootcampProject.git && cd back-end
```

2. Install dependencies using Yarn:

```
yarn
```

3. To compile contracts use:

```
yarn hardhat compile
```

4. To deploy contracts to a local Hardhat network use the command:

```
yarn hardhat deploy
```

5. To deploy contracts to a supported mainnet or testnet use:

```
yarn hardhat deploy --tags main --network <name>
```

> **Note**
> The command above not only deploys your contract to a supported mainnet or testnet, it also verifies it.
> You should have your `.env` file already configured. Check `.env.example`.

6. You can mint and NFT using the command:
```
yarn hardhat deploy --tags mint --network <name>
```

## Presentation

1. ### Does the demo meet the project description?
Yes.

2. ### Has it been compared against real projects?
Yes. Some projects do not implement truly decentralized and random data.

## Solution

1. ### Solution Description
Back in the day, contracts did not have a way to generate truly random data because of the deterministic nature of the EVM.
Nowdays, with the help of Chainlink's VRFs we can implement a true decentralized and random way to generate data.

2. ### General description of the use of Defender in your project.

In our project we implement the use of Defender to increase the security of our application.
Mainly, our application utilizes the Sentinel functionality of Defender; we use it to alert us of suspicious activities or incidences, so our team can act rapidly and accordingly.
Also, our project uses OpenZeppelin's libraries, to avoid and prevent security issues, as we know, those libraries have already been audited, and they really help us to reinvent the wheel.

3. ### Description of the value that Defender brings to my project.

   With the use of defender in our project, it will alert us to avoid the loss of important amount of money due to errors in the minting process by the useres and help them.

4. ### Description of why use module Sentinel defender.

   We use sentinel to alert the community of what is happening with the contract and provide transparency in the minting process.

5. ### Description of how to use the <example_admin> defender module.

   In order to use Sentinel in our projects, we analyzed which functions were important and determined that they were the following:
   1.- revokeRole
   2.- pause
   3.- renounceRole
   4.- unPause
   5.- requestObject

6. ### Do I apply SEC-OPS to my project?

   We apply Sec-Ops and make sure to put restrictions on whitelisted users who cannot mint earlier and whitelisted users who cannot mint more than allowed.

   This prevents them from running the contract functions through Scanners and breaking the security of the process.

   We also use an efficient use of gas.
