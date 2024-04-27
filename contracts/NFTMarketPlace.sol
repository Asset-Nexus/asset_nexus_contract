// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract NFTMarketPlace is ReentrancyGuard, IERC721Receiver {
    address public immutable ASSET_NEXUS_NFT;
    address public immutable ASSET_NEXUS_TOKEN;

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


    constructor(address token, address nft) {
        ASSET_NEXUS_NFT = nft;
        ASSET_NEXUS_TOKEN = token;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) public override  returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function listItem(
        uint price,
        uint tokenId
    )
        external
        isOwner(ASSET_NEXUS_NFT, tokenId, msg.sender)
    {
        if (listing[ASSET_NEXUS_NFT][tokenId].price > 0){
           revert HasListed(ASSET_NEXUS_NFT, tokenId);
        }
        require(price > 0, "Nft price must need over zero!");
        IERC721 nft = IERC721(ASSET_NEXUS_NFT);
        require(
            nft.getApproved(tokenId) == address(this),
            "Current market has not been approved by this nft!"
        );

        nft.safeTransferFrom(msg.sender, address(this), tokenId);
        listing[ASSET_NEXUS_NFT][tokenId] = Listing(price, msg.sender);
        emit ItemListed(msg.sender, ASSET_NEXUS_NFT, tokenId, price);
    }

    function buyItem(
        uint tokenId
    ) external isListed(ASSET_NEXUS_NFT, tokenId) nonReentrant {
        Listing memory curListing = listing[ASSET_NEXUS_NFT][tokenId];
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
        delete listing[ASSET_NEXUS_NFT][tokenId];
       
        IERC721(ASSET_NEXUS_NFT).safeTransferFrom(
            address(this),
            msg.sender,
            tokenId
        );
        emit BuyItem(msg.sender, ASSET_NEXUS_NFT, tokenId, curListing.price);
    }

    function cancelListing(
        uint tokenId
    )
        external
        isOwner(ASSET_NEXUS_NFT, tokenId, address(this))
        isListed(ASSET_NEXUS_NFT, tokenId)
    {
        delete listing[ASSET_NEXUS_NFT][tokenId];
        IERC721(ASSET_NEXUS_NFT).safeTransferFrom(
            address(this),
            msg.sender,
            tokenId
        );
        emit CancelListing(msg.sender, ASSET_NEXUS_NFT, tokenId);
    }

    function updateListing(
        uint tokenId,
        uint newPrice
    )
        external
        isOwner(ASSET_NEXUS_NFT, tokenId, address(this))
        isListed(ASSET_NEXUS_NFT, tokenId)
    {
        listing[ASSET_NEXUS_NFT][tokenId].price = newPrice;
        emit ItemListed(msg.sender, ASSET_NEXUS_NFT, tokenId, newPrice);
    }

    function withDrawProceeds() external {
        uint curProceeds = proceeds[msg.sender];
        require(curProceeds > 0, "you have no proceeds!");
        delete proceeds[msg.sender];
        IERC20(ASSET_NEXUS_TOKEN).transfer(msg.sender, curProceeds);
    }
}
