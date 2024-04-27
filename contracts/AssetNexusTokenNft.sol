// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract AssetNexusNft is ERC721 {
    string public constant fashion_uri =
        "https://ipfs.filebase.io/ipfs/QmTz6ajnLUXwaXCjZ7Zvdk2nXGdQNspnLPsgwZFDP45tUJ/fashion.json";
    string public constant ghost_uri =
        "https://ipfs.filebase.io/ipfs/QmTz6ajnLUXwaXCjZ7Zvdk2nXGdQNspnLPsgwZFDP45tUJ/ghost.json";
    string public constant godfather_uri =
        "https://ipfs.filebase.io/ipfs/QmTz6ajnLUXwaXCjZ7Zvdk2nXGdQNspnLPsgwZFDP45tUJ/godfather.json";
    string public constant smoke_uri =
        "https://ipfs.filebase.io/ipfs/QmTz6ajnLUXwaXCjZ7Zvdk2nXGdQNspnLPsgwZFDP45tUJ/smoke.json";
    uint256 public tokenCounter;

    constructor() ERC721("AssetNexusNFT", "AN_NFT") {
    }

    function mint() public {
        _safeMint(msg.sender, tokenCounter);
        tokenCounter += 1;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(tokenId < tokenCounter, "URI query for nonexistent token");
        if (tokenId % 4 == 0) {
            return fashion_uri;
        } else if (tokenId % 4 == 1) {
            return ghost_uri;
        } else if (tokenId % 4 == 2) {
            return godfather_uri;
        } else {
            return smoke_uri;
        }
    }
}
