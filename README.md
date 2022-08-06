# OpenZeppelin Bootcamp Project

## Project Description

An application to randomly mint NFTs based on probability using Chainlink VRF V2 and OpenZeppelin libraries.
Each token URI points to the token metadata stored in IPFS.

## Authors

-   [antovanFI](https://github.com/antovanFI)
-   [Elizao](https://github.com/Elizao)
-   [irwingtello](https://github.com/irwingtello)
-   [leandrogavidia](https://github.com/leandrogavidia)
-   [mektigboy](https://github.com/mektigboy)

## Innovation

We implement a true decentralized way to generate random data using Chainlink VRF V2.
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

## Presentation

1. ### Does the demo meet the project description?

   Yes

2. ### Has it been compared against real projects?

   Yes, some project dont have Open Zepellin Defender

## Solution

1. ### Solution Description

    NFT Minting Contract(ERC721) for whitelist and rarity

2. ### General description of the use of Defender in your project.

   In the project we use Chainlink and Defender, to increase the security of our solution, we use them as follows:
	Defender : We use sentinel to alert us of suspicious activities or incidences so that we can act within the minting event.
	Chainlink : Request random numbers to determine the rarity
	Solidity: We used the Open Zepellin interfaces for ERC721, to avoid workarounds and use audited contracts that served us in the construction of our solution.

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
