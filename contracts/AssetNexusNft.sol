// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract AssetNexusNft is ERC721URIStorage {
    
    uint256 public tokenCounter;
    event NewNFTMinted(address sender, uint256 tokenId, string tokenURI);

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function mintItem(string memory tokenURI) public returns(uint256){
        _mint(msg.sender, tokenCounter);
        _setTokenURI(tokenCounter, tokenURI);
        emit NewNFTMinted(msg.sender, tokenCounter, tokenURI);
        
        return tokenCounter++;
    }
}
