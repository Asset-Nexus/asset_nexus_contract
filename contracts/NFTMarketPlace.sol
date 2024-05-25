// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "./AssetNexusNft.sol";
import "./AssetNexusToken.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import {Messenger} from "./Messenger.sol";

contract NFTMarketPlace is IERC721Receiver {
    using Strings for string;

    struct NFTSalesInformation {
        address nftAddr;
        uint256 tokenId;
        uint256 price;
        address seller;
        uint256 timestamp;
        uint256 chainId;
    }

    AssetNexusToken public assetNexusToken;
    // Messenger public messenger;
    address public messengerAddr;
    NFTSalesInformation[] public nftSaleInfoList;
    // nftAddress => tokenId => NFTSalesInformation
    mapping(address => mapping(uint256 => NFTSalesInformation))
        public nftListings;
    // eoa address => NFTSalesInformation[]
    mapping(address => NFTSalesInformation[]) public myListings;
    // nft name => nft address
    mapping(string => address) public nftContractsByNames;
    mapping(address => uint256) public proceeds;
    mapping(address => bool) public whitelist;

    event ItemListed(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price,
        uint256 timestamp,
        uint256 chainId
    );
    event UpdateItem(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );
    event BuyItem(
        address indexed buyer,
        address indexed nftAddress,
        uint256 indexed tokenId,
        uint256 price
    );
    event CancelListing(
        address indexed seller,
        address indexed nftAddress,
        uint256 indexed tokenId
    );
    event NewNFTContractCreated(
        address indexed nftAddress,
        string name,
        string symbol
    );
    event changeMessenger(
        address indexed oldMessengerAddr,
        address newMessengerAddr
    );
    event AddWhitelist(address indexed account);
    event RemoveWhitelist(address indexed account);

    error InsufficientBalance(address buyer, uint256 balance, uint256 price);
    error InsufficientApproveLimit(address buyer, uint256 allowance);
    error HasListed(address nftAddress, uint256 tokenId);
    error InvalidRequest(bytes32 requestId);
    error NotApproved(address nftAddress, uint256 tokenId);
    error MessengerNotSet();

    

    modifier isListed(address nftAddress, uint256 tokenId) {
        NFTSalesInformation memory curListing = nftListings[nftAddress][
            tokenId
        ];
        // require(curListing.seller == msg.sender, "This NFT's seller is not current address!");
        require(curListing.price > 0, "Current NFT has no listed!");
        _;
    }

    modifier isOwner(address nftAddress, uint256 tokenId) {
        IERC721 nft = IERC721(nftAddress);
        require(
            nft.ownerOf(tokenId) == msg.sender,
            "This NFT is not belong to current address!"
        );
        _;
    }

    modifier onlyWhitelisted() {
        require(
            whitelist[msg.sender],
            "Only whitelisted addresses can call this function."
        );
        _;
    }

    constructor(address tokenAddr) {
        assetNexusToken = AssetNexusToken(tokenAddr);
    }

    function setNewMessenger(
        address newMessengerAddr
    ) external onlyWhitelisted {
        emit changeMessenger(messengerAddr, newMessengerAddr);
        messengerAddr = newMessengerAddr;
    }

    function getAllListing()
        external
        view
        returns (NFTSalesInformation[] memory)
    {
        return nftSaleInfoList;
    }

    function getMyListing(
        address _owner
    ) external view returns (NFTSalesInformation[] memory) {
        return myListings[_owner];
    }

    function createAssetNexusNft(
        string memory name,
        string memory symbol
    ) external onlyWhitelisted {
        bytes32 _salt = keccak256(abi.encodePacked(name, symbol));
        AssetNexusNft newNft = new AssetNexusNft{salt: _salt}(name, symbol);
        address newAddr = address(newNft);
        nftContractsByNames[name] = newAddr;
        emit NewNFTContractCreated(newAddr, name, symbol);
    }

    function onERC721Received(
        address /* operator */,
        address /* from */,
        uint256 /* tokenId */,
        bytes calldata /* data */
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function listItem(
        address nftAddr,
        uint256 tokenId,
        uint256 price,
        uint chainId,
        bool isCrossChain
    ) external {
        IERC721 nft = IERC721(nftAddr);

        if (nftListings[nftAddr][tokenId].price > 0) {
            revert HasListed(nftAddr, tokenId);
        }

        if (!isCrossChain) {
            nft.safeTransferFrom(msg.sender, address(this), tokenId);
        }

        NFTSalesInformation memory newListing = NFTSalesInformation({
            price: price,
            seller: msg.sender,
            nftAddr: nftAddr,
            tokenId: tokenId,
            timestamp: block.timestamp,
            chainId: chainId
        });

        nftListings[nftAddr][tokenId] = newListing;
        myListings[msg.sender].push(newListing);
        nftSaleInfoList.push(newListing);
        emit ItemListed(
            msg.sender,
            nftAddr,
            tokenId,
            price,
            block.timestamp,
            chainId
        );
    }

    function buyItem(
        address nftAddr,
        uint256 tokenId,
        uint64 destinationChainSelector,
        address receiver,
        bool isCrossChain
    ) external isListed(nftAddr, tokenId) {
        NFTSalesInformation memory curListing = nftListings[nftAddr][tokenId];
        assetNexusToken.transferFrom(
            msg.sender,
            address(this),
            curListing.price
        );
        proceeds[curListing.seller] += curListing.price;
        delete nftListings[nftAddr][tokenId];

        if (isCrossChain) {
            if (messengerAddr == address(0)) {
                revert MessengerNotSet();
            }
            bytes memory data = abi.encodeWithSignature(
                "transferFrom(address,address,uint256)",
                curListing.seller,
                msg.sender,
                curListing.tokenId
            );
            Messenger(payable(messengerAddr)).sendMessagePayLINK(
                destinationChainSelector,
                receiver,
                data
            );
        } else {
            IERC721(nftAddr).safeTransferFrom(
                address(this),
                msg.sender,
                tokenId
            );
        }

        handleRemove(nftSaleInfoList, nftAddr, tokenId);
        handleRemove(myListings[curListing.seller], nftAddr, tokenId);
        emit BuyItem(msg.sender, nftAddr, tokenId, curListing.price);
    }

    function cancelListing(
        address nftAddr,
        uint256 tokenId
    ) external isListed(nftAddr, tokenId) {
        delete nftListings[nftAddr][tokenId];
        handleRemove(myListings[msg.sender], nftAddr, tokenId);
        handleRemove(nftSaleInfoList, nftAddr, tokenId);

        IERC721(nftAddr).safeTransferFrom(address(this), msg.sender, tokenId);
        emit CancelListing(msg.sender, nftAddr, tokenId);
    }

    function updateListing(
        address nftAddr,
        uint256 tokenId,
        uint256 newPrice
    ) external isListed(nftAddr, tokenId) {
        nftListings[nftAddr][tokenId].price = newPrice;
        handleUpdate(myListings[msg.sender], nftAddr, tokenId, newPrice);
        handleUpdate(nftSaleInfoList, nftAddr, tokenId, newPrice);

        emit UpdateItem(msg.sender, nftAddr, tokenId, newPrice);
    }

    function withDrawProceeds() external {
        uint256 curProceeds = proceeds[msg.sender];
        require(curProceeds > 0, "you have no proceeds!");
        delete proceeds[msg.sender];
        assetNexusToken.transfer(msg.sender, curProceeds);
    }

    function addAddressToWhitelist(address _address) external {
        whitelist[_address] = true;
        emit AddWhitelist(_address);
    }

    function removeAddressFromWhitelist(address _address) external {
        whitelist[_address] = false;
        emit RemoveWhitelist(_address);
    }

    function handleRemove(
        NFTSalesInformation[] storage listings,
        address nftAddr,
        uint256 tokenId
    ) internal {
        for (uint256 i = 0; i < listings.length; i++) {
            if (
                listings[i].nftAddr == nftAddr && listings[i].tokenId == tokenId
            ) {
                listings[i] = listings[listings.length - 1];
                listings.pop();
                break;
            }
        }
    }

    function handleUpdate(
        NFTSalesInformation[] storage listings,
        address nftAddr,
        uint256 tokenId,
        uint256 newPrice
    ) internal {
        for (uint256 i = 0; i < listings.length; i++) {
            if (
                listings[i].nftAddr == nftAddr && listings[i].tokenId == tokenId
            ) {
                listings[i].price = newPrice;
                break;
            }
        }
    }
}
