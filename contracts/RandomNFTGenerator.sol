// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

/// @title Random NFT Generator
/// @author antovanFI, Elizao, irwingtello, leandrogavidia, mektigboy
/// @notice Generates NFTs with randomness, and store them in a decentralized way.
/// @dev This contract utilizes Chainlink VRF v2 for randomness.
/// URIs point to IPFS.
/// Imports contracts from OpenZeppelin.
contract RandomNFTGenerator is ERC721URIStorage, VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface immutable i_VRFCoordinator;
    bytes32 immutable i_gasLane;
    uint64 immutable i_subscriptionId;
    uint32 immutable i_callbackGasLimit;

    uint16 constant REQ_CONFIRMATIONS = 3;
    uint32 constant NUM_WORDS = 1;
    uint256 constant MAX_CHANCE = 1000;

    mapping(uint256 => address) s_requestIdToSender;
    string[3] public s_tokenURIs;

    uint256 public s_tokenCounter;

    constructor(
        address VRFCoordinatorV2,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        string[3] memory tokenURIs
    )
        ERC721("OpenZeppelin Bootcamp Project", "OBP")
        VRFConsumerBaseV2(VRFCoordinatorV2)
    {
        i_VRFCoordinator = VRFCoordinatorV2Interface(VRFCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_tokenCounter = 0;
        s_tokenURIs = tokenURIs;
    }

    // Mint a random NFT:

    // 1. Get random number.
    function requestObject() public returns (uint256 requestId) {
        requestId = i_VRFCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQ_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        s_requestIdToSender[requestId] = msg.sender;
    }

    // 2. Mint NFT.
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        // Owner of the object.
        address tokenOwner = s_requestIdToSender[requestId];
        // Asign this NFT a <tokenId>.
        uint256 newTokenId = s_tokenCounter;
        s_tokenCounter = s_tokenCounter + 1;
        uint256 moddedRng = randomWords[0] % MAX_CHANCE; // Random number generated.
        uint256 selection = selectFromModdedRng(moddedRng);
        _safeMint(tokenOwner, newTokenId);
        _setTokenURI(newTokenId, s_tokenURIs[selection]);
    }

    function getChanceArray() public pure returns (uint256[3] memory) {
        // 0 - 10 = Epic
        // 11 - 100 = Rare
        // 101 - 1000 = Common
        return [10, 100, MAX_CHANCE];
    }

    function selectFromModdedRng(uint256 moddedRng)
        public
        pure
        returns (uint256)
    {
        uint256 cumulativeSum = 0;
        uint256[3] memory chanceArray = getChanceArray();

        for (uint256 i = 0; i < chanceArray.length; i++) {
            if (
                moddedRng >= cumulativeSum &&
                moddedRng < cumulativeSum + chanceArray[i]
            ) return i;
            cumulativeSum = cumulativeSum + chanceArray[i];
        }
    }

    function getVRFCoordinator()
        public
        view
        returns (VRFCoordinatorV2Interface)
    {
        return i_VRFCoordinator;
    }

    function getGasLane() public view returns (bytes32) {
        return i_gasLane;
    }

    function getSubscriptionID() public view returns (uint64) {
        return i_subscriptionId;
    }

    function getCallbackGasLimit() public view returns (uint32) {
        return i_callbackGasLimit;
    }
}
