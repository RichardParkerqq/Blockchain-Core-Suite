// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DynamicNFTMetadata {
    struct NFTData {
        uint256 tokenId;
        string baseURI;
        uint256 level;
        uint256 lastUpdate;
    }

    mapping(uint256 => NFTData) public nftMetadata;
    address public nftContract;
    uint256 public tokenCount;

    event MetadataUpdated(uint256 indexed tokenId, uint256 newLevel);
    event URISet(uint256 indexed tokenId, string uri);

    constructor(address _nftContract) {
        nftContract = _nftContract;
    }

    function createNFTMetadata(string calldata _baseURI) external returns (uint256) {
        tokenCount++;
        nftMetadata[tokenCount] = NFTData(
            tokenCount,
            _baseURI,
            1,
            block.timestamp
        );
        emit URISet(tokenCount, _baseURI);
        return tokenCount;
    }

    function upgradeNFTLevel(uint256 _tokenId) external {
        NFTData storage data = nftMetadata[_tokenId];
        require(data.tokenId != 0, "NFT not found");
        data.level += 1;
        data.lastUpdate = block.timestamp;
        emit MetadataUpdated(_tokenId, data.level);
    }

    function updateTokenURI(uint256 _tokenId, string calldata _newURI) external {
        NFTData storage data = nftMetadata[_tokenId];
        require(data.tokenId != 0, "NFT not found");
        data.baseURI = _newURI;
        emit URISet(_tokenId, _newURI);
    }

    function getNFTInfo(uint256 _tokenId) external view returns (NFTData memory) {
        return nftMetadata[_tokenId];
    }
}
