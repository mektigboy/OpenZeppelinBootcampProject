// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @title Random NFT Generator
/// @author antovanFI, Elizao, irwingtello, leandrogavidia, mektigboy
/// @notice Generates NFTs with randomness, and store them in a decentralized way.
/// @dev This contract utilizes Chainlink VRF v2 for randomness.
/// URIs point to IPFS.
/// Imports contracts from OpenZeppelin.
contract AbitoRandomNFTGenerator is  ERC721URIStorage, VRFConsumerBaseV2, Pausable, AccessControl {
    /*
        Start WhiteList variables
    */
        using Counters for Counters.Counter;
        bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
        bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
        Counters.Counter private _tokenIdCounter;

        // The number of accounts we want to have in our whitelist.
        uint256 public maxNumberOfWhitelistedAddresses;

        // Track the number of whitelisted addresses.
        uint256 public numberOfAddressesWhitelisted;

        // The owner of the contract
        address owner;

        // To store our addresses, we need to create a mapping that will receive the user's address and return if he is whitelisted or not.
        mapping(address => bool) whitelistedAddresses;

        // Control NFTs in the contract
        uint256 public maxNFTLimit;
        uint256 public maxNFTLimitWhitelist;
        uint256 public nftMinted;
    /*
        END WhiteList variables
    */

    /*
        Start WhiteList modifiers
    */
    modifier verifyWhiteListLimit(){
        //Se gasta poco gas, y es engorroso porque va ir al minteo publico
        require( maxNFTLimitWhitelist<=nftMinted, "Sorry go to the public minting!");
        _;
    }

    modifier enablePublicMinting()
    {
        require(maxNFTLimit<=nftMinted,"Sorry we are empty in stock");
        require(maxNFTLimitWhitelist>nftMinted, "Please wait,whitelist minting are in progress");
        _;
    }
    /*
        END WhiteList modifiers
    */


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
        uint256 _maxWhitelistedAddresses,
        uint256 _maxNFTLimit,
        uint256 _maxNFTLimitWhitelist,
        address VRFCoordinatorV2,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        string[3] memory tokenURIs
    )
        ERC721("ABITO", "ABI")
        VRFConsumerBaseV2(VRFCoordinatorV2)
    {
        i_VRFCoordinator = VRFCoordinatorV2Interface(VRFCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_tokenCounter = 0;
        s_tokenURIs = tokenURIs;

        //bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        
        //Variables for Whitelist
        maxNumberOfWhitelistedAddresses = _maxWhitelistedAddresses;
        maxNFTLimit=_maxNFTLimit;
        maxNFTLimitWhitelist=_maxNFTLimitWhitelist;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /*
        Start WhiteList functions
    */
    function addUserAddressToWhitelist(address _addressToWhitelist)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        // Validate the caller is not already part of the whitelist.
        require(
            !whitelistedAddresses[_addressToWhitelist],
            "Error: Sender already been whitelisted"
        );

        // Validate if the maximum number of whitelisted addresses is not reached. If not, then throw an error.
        require(
            numberOfAddressesWhitelisted < maxNumberOfWhitelistedAddresses,
            "Error: Whitelist Limit exceeded"
        );

        // Set whitelist boolean to true.
        whitelistedAddresses[_addressToWhitelist] = true;

        // Increasing the count
        numberOfAddressesWhitelisted += 1;
    }

    // Remove user from whitelist
    function removeUserAddressFromWhitelist(address _addressToRemove)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        // Validate the caller is already part of the whitelist.
        require(
            whitelistedAddresses[_addressToRemove],
            "Error: Sender is not whitelisted"
        );

        // Set whitelist boolean to false.
        whitelistedAddresses[_addressToRemove] = false;

        // This will decrease the number of whitelisted addresses.
        numberOfAddressesWhitelisted -= 1;
    }

    // Get the number of whitelisted addresses
    function getNumberOfWhitelistedAddresses() public view returns (uint256) {
        return numberOfAddressesWhitelisted;
    }

    // Get the maximum number of whitelisted addresses
    function getMaxNumberOfWhitelistedAddresses()
        public
        view
        returns (uint256)
    {
        return maxNumberOfWhitelistedAddresses;
    }
        //Si el usuario no esta en la whitelist, devuelve un false
    function verifyUserAddress(address _whitelistedAddress)
        public
        view
        returns (bool)
    {
        // Verifying if the user has been whitelisted
        bool userIsWhitelisted = whitelistedAddresses[_whitelistedAddress];
        return userIsWhitelisted;
    }
        // Is the user whitelisted?
    function isWhitelisted(address _whitelistedAddress)
        public
        view
        returns (bool)
    {
        // Verifying if the user has been whitelisted
        return whitelistedAddresses[_whitelistedAddress];
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
    //Viene directo desde el VRF
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

    //Mint usuarios whitelist (utilizando modifier para verificar NFTs)
    //Tiene que ponerse los parametros
    //---
    function mintWhiteList(uint256 requestId, uint256[] memory randomWords) public verifyWhiteListLimit {     

        require(isWhitelisted(msg.sender), "User is not whitelisted");        
        requestObject();
        fulfillRandomWords(requestId,randomWords);



    }
    
    //Mint usuarios sin whitelist
    function publicMint(uint256 requestId, uint256[] memory randomWords) public enablePublicMinting {

        requestObject();

        fulfillRandomWords(requestId,randomWords);

    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }
    // The following functions are overrides required by Solidity.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
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