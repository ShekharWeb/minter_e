// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

/**
 * @title Minter contract
 * @dev Extends ERC721Enumerable Non-Fungible Token Standard
 */
contract Minter is ERC721Enumerable {
    using Strings for uint256;


    // Contract global variables.
    uint256 public constant mintPrice = 3 * 10**16; // 0.03 ETH.
    uint256 public constant maxMint = 10;
    uint256 public MAX_TOKENS = 10000;

    string private __baseURI;
    string private _uriExtention = ".json";

    address private admin;

    constructor(address _admin, string memory _base) ERC721("Minter", "MINTER") {
         admin = _admin;
        __baseURI = _base;
        // ipfs://CID/
    }

    modifier onlyAdmin{
      require(msg.sender == admin);
      _;
   }

    // The main token minting function (recieves Ether).
    function mint(uint256 numberOfTokens) public payable {
        // Number of tokens can't be 0.
        require(numberOfTokens != 0, "You need to mint at least 1 token");
        // Check that the number of tokens requested doesn't exceed the max. allowed.
        require(numberOfTokens <= maxMint, "You can only mint 10 tokens at a time");
        // Check that the number of tokens requested wouldn't exceed what's left.
        require(totalSupply() + numberOfTokens <= MAX_TOKENS, "Minting would exceed max. supply");
        // Check that the right amount of Ether was sent.
        require(mintPrice + numberOfTokens <= msg.value, "Not enough Ether sent.");

        // For each token requested, mint one.
        for(uint256 i = 0; i < numberOfTokens; i++) {
            uint256 mintIndex = totalSupply();
            if(mintIndex < MAX_TOKENS) {
                /** 
                 * Mint token using inherited ERC721 function
                 * msg.sender is the wallet address of mint requester
                 * mintIndex is used for the tokenId (must be unique)
                 */
                _safeMint(msg.sender, mintIndex);
            }
        }
    }

    function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

    function tokenURI(uint256 _tokenId) public view virtual override returns(string memory){
        require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
        string memory baseURI = __baseURI;
        return string(abi.encodePacked(baseURI, _tokenId.toString(),_uriExtention));
    }
    
    function withdrawBalance(address _to) public onlyAdmin {
        (bool os, ) = payable(_to).call{value: address(this).balance}("");
        require(os);
    }
    function adminBalance() public view onlyAdmin returns(uint256) {
        return  address(this).balance;
    }

    function setBaseURI(string memory _newBaseURI) public onlyAdmin {
        __baseURI = _newBaseURI;
    }

    
    function setBaseUriExtention(string memory _newBaseExtension) public onlyAdmin {
        _uriExtention = _newBaseExtension;
    }
}