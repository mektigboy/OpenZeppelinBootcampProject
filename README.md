# OpenZeppelin Bootcamp Project

## Project Description

An application to randomly mint NFTs based on probability using Chainlink's VRF v2 and OpenZeppelin libraries.
Each token URI points to the token metadata stored in IPFS.

## Authors

- [antovanFI](https://github.com/antovanFI)
- [Elizao](https://github.com/Elizao)
- [irwingtello](https://github.com/irwingtello)
- [leandrogavidia](https://github.com/leandrogavidia)
- [mektigboy](https://github.com/mektigboy)

## Innovation

Back in the day, contracts did not have a way to generate truly random data because of the deterministic nature of the EVM.
Nowdays, with the help of Chainlink's VRFs we can implement a true decentralized and random way to generate data using Chainlink's VRF V2.
Also, our contracts use the latest version of Solidity, and the v0.8 OpenZeppelin libraries, which are up-to-date.

## Usage & Installation

1. Clone the repository, and "cd" into the back-end folder:

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
> The command above not only deploys your contracts to a supported mainnet or testnet, it also verifies them.
> You should have your `.env` file already configured. Check `.env.example`.

6. You can mint and NFT using the command:

```
yarn hardhat deploy --tags mint --network <name>
```

## Presentation

### Does the demo meet the project description?

Yes.

### Has it been compared against real projects?

Yes. Some projects do not implement truly decentralized and random data.

## Solution

### Solution Description

A common problem in the "traditional web" is the transparency of randomness and scarcity.

If you buy a trading card, lets say, you buy a first edition of Michael Jordan or Scottie Pippen basketball card, you have no way of knowing how rare it really is without talking to the company that printed it. There is a centralized component to the scarcity of the card. They could have printed millions, making it worthless, or just 1, making it incredibly rare, you really do not know!

With NFTs, if you are the one who can control how rare the asset is, you are a centralized component of rarity.

If we use Chainlink's VRF to mint the digital assets, you have no control of how rare the asset is, you can rely on true randomness. This gives us a proven way to know how rare and scarce our digital assets are, making them more valuable and tamper-proof.

This solves the centralized issue of diluting the value of NFTs by printing more "rare" ones, giving them actual value.

### General description of the use of Defender in your project.

In our project we implement the use of Defender to increase the security of our application.
Mainly, our application utilizes the Sentinel functionality of Defender; we use it to alert us of suspicious activities or incidences, so our team can act rapidly and accordingly.
Also, our project uses OpenZeppelin's libraries, to avoid and prevent security issues; as we already know, those libraries have already been audited, and they really help us to not reinvent the wheel.

### Description of the value that Defender brings to my project.

The main thing about working with cryptocurrencies and cryptoassets is that they posses true monetary value.
Defender can help us and alert us to avoid the loss of those assets due to security-related issues.

### Description of why use module Sentinel Defender.

We use sentinel to alert the community of what is happening with the contract and provide transparency in the minting process.

### Description of how to use the <example_admin> Defender module.

In order to use Sentinel in our projects, we analyzed which functions were the most relevant, and determined that the most important functions were the following:
1.- revokeRole
2.- pause
3.- renounceRole
4.- unPause
5.- requestObject

### Do I apply SEC-OPS to my project?

We apply SecOps to add extra layers of security that help us prevent future problems.
