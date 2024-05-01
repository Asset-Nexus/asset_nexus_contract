// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./AssetNexusNft.sol";

contract NFTMarketPlace is ReentrancyGuard, IERC721Receiver {
    address public immutable ASSET_NEXUS_TOKEN;

    // mapping(bytes32 => address) public nftList;
    address[] public nftList;

    struct Listing {
        uint price;
        address seller;
    }

    event ItemListed(
        address indexed seller,
        address indexed nftAddress,
        uint indexed tokenId,
        uint price
    );
    event BuyItem(
        address indexed buyer,
        address indexed nftAddress,
        uint indexed tokenId,
        uint price
    );

    event CancelListing(
        address indexed seller,
        address indexed nftAddress,
        uint indexed tokenId
    );

    event NewNFTContractCreated(
        address indexed nftAddress,
        uint index,
        string name,
        string symbol
    );

    mapping(address => mapping(uint => Listing)) public listing;
    mapping(address => uint) public proceeds;

    modifier isListed(address nftAddress, uint tokenId) {
        Listing memory curListing = listing[nftAddress][tokenId];
        require(curListing.price > 0, "Current NFT has no listed!");
        _;
    }

    modifier isOwner(
        address nftAddress,
        uint tokenId,
        address spender
    ) {
        IERC721 nft = IERC721(nftAddress);
        require(
            nft.ownerOf(tokenId) == spender,
            "This NFT is not belong to current address!"
        );
        _;
    }

    error InsufficientBalance(address buyer, uint balance, uint price);
    error InsufficientApproveLimit(address buyer, uint allowance);
    error HasListed(address nftAddress, uint tokenId);

    constructor(address token) {
        ASSET_NEXUS_TOKEN = token;
    }

    function generateSalt(string memory name, string memory symbol) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(name, symbol));
    }

    function createAssetNexusNft(
        string memory name,
        string memory symbol
    ) public returns (uint) {
        bytes32 _salt = generateSalt(name, symbol);
        AssetNexusNft newNft = new AssetNexusNft{salt: _salt}(name, symbol);
        address newAddr = address(newNft);
        nftList.push(newAddr);
        emit NewNFTContractCreated(newAddr, nftList.length - 1,name, symbol);
        return nftList.length - 1;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) public override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function listItem(
        address nftAddress,
        uint price,
        uint tokenId
    ) external isOwner(nftAddress, tokenId, msg.sender) {
        if (listing[nftAddress][tokenId].price > 0) {
            revert HasListed(nftAddress, tokenId);
        }
        require(price > 0, "Nft price must need over zero!");
        IERC721 nft = IERC721(nftAddress);
        require(
            nft.getApproved(tokenId) == address(this),
            "Current market has not been approved by this nft!"
        );

        nft.safeTransferFrom(msg.sender, address(this), tokenId);
        listing[nftAddress][tokenId] = Listing(price, msg.sender);
        emit ItemListed(msg.sender, nftAddress, tokenId, price);
    }

    function buyItem(
        address nftAddress,
        uint tokenId
    ) external isListed(nftAddress, tokenId) nonReentrant {
        Listing memory curListing = listing[nftAddress][tokenId];
        IERC20 token = IERC20(ASSET_NEXUS_TOKEN);
        uint allowanceAmount = token.allowance(msg.sender, address(this));
        uint balance = token.balanceOf(msg.sender);

        if (allowanceAmount < curListing.price) {
            revert InsufficientApproveLimit(msg.sender, allowanceAmount);
        }
        if (balance < curListing.price) {
            revert InsufficientBalance(msg.sender, balance, curListing.price);
        }

        token.transferFrom(msg.sender, address(this), curListing.price);
        proceeds[curListing.seller] += curListing.price;
        delete listing[nftAddress][tokenId];

        IERC721(nftAddress).safeTransferFrom(
            address(this),
            msg.sender,
            tokenId
        );
        emit BuyItem(msg.sender, nftAddress, tokenId, curListing.price);
    }

    function cancelListing(
        address nftAddress,
        uint tokenId
    )
        external
        isOwner(nftAddress, tokenId, address(this))
        isListed(nftAddress, tokenId)
    {
        delete listing[nftAddress][tokenId];
        IERC721(nftAddress).safeTransferFrom(
            address(this),
            msg.sender,
            tokenId
        );
        emit CancelListing(msg.sender, nftAddress, tokenId);
    }

    function updateListing(
        address nftAddress,
        uint tokenId,
        uint newPrice
    )
        external
        isOwner(nftAddress, tokenId, address(this))
        isListed(nftAddress, tokenId)
    {
        listing[nftAddress][tokenId].price = newPrice;
        emit ItemListed(msg.sender, nftAddress, tokenId, newPrice);
    }

    function withDrawProceeds() external {
        uint curProceeds = proceeds[msg.sender];
        require(curProceeds > 0, "you have no proceeds!");
        delete proceeds[msg.sender];
        IERC20(ASSET_NEXUS_TOKEN).transfer(msg.sender, curProceeds);
    }
}
