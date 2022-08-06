// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

error AbitoRandomNFTGenerator__AlreadyInitialized();
error AbitoRandomNFTGenerator__NotEnoughETHSent();
error AbitoRandomNFTGenerator__NotWhitelisted();
error AbitoRandomNFTGenerator__RangeOutOfScope();
error AbitoRandomNFTGenerator__TransferFailed();

/// @title AbitoRandomNFTGenerator
/// @author antovanFI, Elizao, irwingtello, leandrogavidia, mektigboy
/// @notice Generates NFTs with randomness. Store them in a decentralized way.
/// @dev This contract utilizes Chainlink VRF v2 to generate random data.
/// URIs point to IPFS.
/// Imports from OpenZeppelin.
contract AbitoRandomNFTGenerator is
    AccessControl,
    ERC721URIStorage,
    Ownable,
    Pausable,
    VRFConsumerBaseV2
{
    // Type Declaration
    enum Selection {
        EPIC,
        RARE,
        COMMON
    }

    // Whitelist Variables
    using Counters for Counters.Counter;
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    Counters.Counter private _tokenIdCounter;

    uint256 public maxNumberOfWhitelistedAddresses;
    uint256 public numberOfAddressesWhitelisted;

    mapping(address => bool) whitelistedAddresses;

    uint256 public maxNFTLimit;
    uint256 public maxNFTLimitWhitelist;
    uint256 public nftMinted;

    // Chainlink VRF Variables
    VRFCoordinatorV2Interface immutable i_coordinator;
    uint64 immutable i_subscriptionId;
    bytes32 immutable i_gasLane;
    uint32 immutable i_callbackGasLimit;
    uint16 constant REQ_CONFIRMATIONS = 3;
    uint32 constant NUM_WORDS = 1;

    // NFT Variables
    uint256 i_mintFee;
    uint256 public s_tokenCounter;
    mapping(uint256 => Selection) private s_tokenIdToBreed;
    uint256 internal constant MAX_CHANCE = 1000;
    string[] internal s_tokenURIs;
    bool s_initialized;

    // VRF Helpers
    mapping(uint256 => address) public s_requestIdToSender;

    // Events
    event NFTRequested(uint256 indexed requestId, address requester);
    event NFTMinted(Selection selection, address minter);

    // Modifiers
    modifier verifyWhitelistLimit() {
        require(maxNFTLimitWhitelist <= nftMinted, "Whitelist max. limit.");
        _;
    }

    modifier enablePublicMinting() {
        require(maxNFTLimit <= nftMinted, "No more stock.");
        require(
            maxNFTLimitWhitelist > nftMinted,
            "Whitelist minting is in progress."
        );
        _;
    }

    modifier requireMintFee() {
        if (msg.value < i_mintFee) {
            revert AbitoRandomNFTGenerator__NotEnoughETHSent();
        }
        _;
    }

    constructor(
        uint256 _maxWhitelistedAddresses,
        uint256 _maxNFTLimit,
        uint256 _maxNFTLimitWhitelist,
        address coordinator,
        uint64 subscriptionId,
        bytes32 gasLane,
        uint32 callbackGasLimit,
        string[3] memory tokenURIs, // Set token URIs in the constructor of our contract.
        uint256 mintFee
    )
        ERC721("OpenZeppelin Bootcamp Project", "OBP")
        VRFConsumerBaseV2(coordinator)
    {
        i_coordinator = VRFCoordinatorV2Interface(coordinator);
        i_subscriptionId = subscriptionId;
        i_gasLane = gasLane;
        i_mintFee = mintFee;
        i_callbackGasLimit = callbackGasLimit;
        _initializeContract(tokenURIs);

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);

        maxNumberOfWhitelistedAddresses = _maxWhitelistedAddresses;
        maxNFTLimit = _maxNFTLimit;
        maxNFTLimitWhitelist = _maxNFTLimitWhitelist;
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    // Whitelist Functions
    function addUserAddressToWhitelist(address _addressToWhitelist)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            !whitelistedAddresses[_addressToWhitelist],
            "Sender already whitelisted."
        );
        require(
            numberOfAddressesWhitelisted < maxNumberOfWhitelistedAddresses,
            "Whitelist limit exceeded."
        );
        whitelistedAddresses[_addressToWhitelist] = true;
        numberOfAddressesWhitelisted += 1;
    }

    function removeUserAddressFromWhitelist(address _addressToRemove)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        require(
            whitelistedAddresses[_addressToRemove],
            "Sender is not whitelisted."
        );
        whitelistedAddresses[_addressToRemove] = false;
        numberOfAddressesWhitelisted -= 1;
    }

    function getNumberOfWhitelistedAddresses() public view returns (uint256) {
        return numberOfAddressesWhitelisted;
    }

    function getMaxNumberOfWhitelistedAddresses()
        public
        view
        returns (uint256)
    {
        return maxNumberOfWhitelistedAddresses;
    }

    function verifyUserAddress(address _whitelistedAddress)
        public
        view
        returns (bool)
    {
        bool userIsWhitelisted = whitelistedAddresses[_whitelistedAddress];
        return userIsWhitelisted;
    }

    function isWhitelisted(address _whitelistedAddress)
        public
        view
        returns (bool)
    {
        return whitelistedAddresses[_whitelistedAddress];
    }

    // Mint a random NFT:

    // 1. Get random number.
    function whitelistMint()
        public
        payable
        verifyWhitelistLimit
        requireMintFee
        returns (uint256 requestId)
    {
        if (!isWhitelisted(msg.sender)) {
            revert AbitoRandomNFTGenerator__NotWhitelisted();
        }
        requestId = i_coordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQ_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        s_requestIdToSender[requestId] = msg.sender;
        emit NFTRequested(requestId, msg.sender);
    }

    function publicMint()
        public
        payable
        enablePublicMinting
        requireMintFee
        returns (uint256 requestId)
    {
        requestId = i_coordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQ_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        s_requestIdToSender[requestId] = msg.sender;
        emit NFTRequested(requestId, msg.sender);
    }

    // 2. Mint NFT.
    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        address tokenOwner = s_requestIdToSender[requestId];
        uint256 newTokenId = s_tokenCounter;
        s_tokenCounter = s_tokenCounter + 1;
        uint256 moddedRNG = randomWords[0] % MAX_CHANCE;
        Selection selection = selectionFromModdedRNG(moddedRNG);
        _safeMint(tokenOwner, newTokenId);
        _setTokenURI(newTokenId, s_tokenURIs[uint256(selection)]);
        emit NFTMinted(selection, tokenOwner);
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert AbitoRandomNFTGenerator__TransferFailed();
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function setChanceArray() public pure returns (uint256[3] memory) {
        // 0 - 10 = Epic
        // 11 - 100 = Rare
        // 101 - 1000 = Common
        return [10, 100, MAX_CHANCE];
    }

    function selectionFromModdedRNG(uint256 moddedRNG)
        public
        pure
        returns (Selection)
    {
        uint256 cumulativeSum = 0;
        uint256[3] memory chanceArray = setChanceArray();

        for (uint256 i = 0; i < chanceArray.length; i++) {
            if (
                moddedRNG >= cumulativeSum &&
                moddedRNG < cumulativeSum + chanceArray[i]
            ) {
                return Selection(i);
            }
            cumulativeSum = chanceArray[i];
        }
        revert AbitoRandomNFTGenerator__RangeOutOfScope();
    }

    function _initializeContract(string[3] memory tokenURIs) private {
        if (s_initialized) {
            revert AbitoRandomNFTGenerator__AlreadyInitialized();
        }
        s_tokenURIs = tokenURIs;
        s_initialized = true;
    }

    // Getters:

    function getInitialized() public view returns (bool) {
        return s_initialized;
    }

    function getMintFee() public view returns (uint256) {
        return i_mintFee;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }

    function getTokenURIs(uint256 index) public view returns (string memory) {
        return s_tokenURIs[index];
    }
}
