// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/// @custom:security-contact equipo1
contract ABITO is ERC721, Pausable, AccessControl {
    using Counters for Counters.Counter;

    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    Counters.Counter private _tokenIdCounter;

    /*
        Start WhiteList variables
    */
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
    uint256 public nftMinted;
    /*
        END WhiteList variables
    */

    /*
        Start WhiteList modifiers
    */
    modifier verifyWhiteListLimit(){
        //Se gasta poco gas, y es engorroso porque va ir al minteo publico
        require( maxNFTLimit<=nftMinted, "Sorry go to the public minting!");
        _;
    }
    /*
        END WhiteList modifiers
    */

    constructor(uint256 _maxWhitelistedAddresses,uint256 _maxNFTLimit) ERC721("ABITO", "ABI") {
        //bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(PAUSER_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        
        //Variables for Whitelist
        maxNumberOfWhitelistedAddresses = _maxWhitelistedAddresses;
        maxNFTLimit=_maxNFTLimit;
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
    /*
        END WhiteList functions
    */
    
    /* Función base
    function safeMint(address to) public onlyRole(MINTER_ROLE) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }*/
    
    //Mint usuarios whitelist (utilizando modifier para verificar NFTs)
    function mintWhiteList(address to) public onlyRole(MINTER_ROLE) verifyWhiteListLimit {
        uint256 tokenId = _tokenIdCounter.current();        
        require(isWhitelisted(to), "User is not whitelisted");        
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }
    
    //Mint usuarios sin whitelist
    function safeMint(address to) public onlyRole(MINTER_ROLE) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
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
}
