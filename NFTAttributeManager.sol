// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract NFTAttributeManager {
    struct Attribute {
        string traitType;
        string value;
        uint256 rarityScore;
    }

    mapping(uint256 => Attribute[]) public nftAttributes;
    address public immutable manager;

    event AttributeAdded(uint256 indexed tokenId, string traitType);

    modifier onlyManager() {
        require(msg.sender == manager, "Not manager");
        _;
    }

    constructor() {
        manager = msg.sender;
    }

    function addAttribute(uint256 _tokenId, string calldata _trait, string calldata _value, uint256 _rarity) external onlyManager {
        nftAttributes[_tokenId].push(Attribute(_trait, _value, _rarity));
        emit AttributeAdded(_tokenId, _trait);
    }

    function getAttributes(uint256 _tokenId) external view returns (Attribute[] memory) {
        return nftAttributes[_tokenId];
    }

    function getAttributeCount(uint256 _tokenId) external view returns (uint256) {
        return nftAttributes[_tokenId].length;
    }
}
