// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC721 {
    function transferFrom(address, address, uint256) external;
    function ownerOf(uint256) external view returns (address);
}

contract NFTMarketplaceBasic {
    struct Listing {
        uint256 tokenId;
        address seller;
        uint256 price;
        bool active;
    }

    mapping(uint256 => Listing) public listings;
    address public immutable nftContract;
    uint256 public listingFee = 0.001 ether;

    event NFTListed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event NFTSold(uint256 indexed tokenId, address indexed buyer);

    constructor(address _nft) {
        nftContract = _nft;
    }

    function listNFT(uint256 _tokenId, uint256 _price) external payable {
        require(msg.value == listingFee, "Invalid fee");
        require(IERC721(nftContract).ownerOf(_tokenId) == msg.sender, "Not owner");
        
        listings[_tokenId] = Listing(
            _tokenId,
            msg.sender,
            _price,
            true
        );
        emit NFTListed(_tokenId, msg.sender, _price);
    }

    function buyNFT(uint256 _tokenId) external payable {
        Listing storage l = listings[_tokenId];
        require(l.active && msg.value == l.price, "Invalid purchase");
        
        l.active = false;
        IERC721(nftContract).transferFrom(l.seller, msg.sender, _tokenId);
        payable(l.seller).transfer(msg.value);
        emit NFTSold(_tokenId, msg.sender);
    }

    function getListing(uint256 _tokenId) external view returns (Listing memory) {
        return listings[_tokenId];
    }
}
