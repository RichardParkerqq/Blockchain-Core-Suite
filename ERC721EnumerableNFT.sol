// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ERC721EnumerableNFT {
    string public name;
    string public symbol;
    uint256 public totalSupply;
    
    mapping(uint256 => address) public ownerOf;
    mapping(address => uint256[]) public tokensOfOwner;
    mapping(uint256 => uint256) public tokenIndex;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Mint(address indexed to, uint256 tokenId);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function mint(address _to) external returns (uint256) {
        totalSupply++;
        uint256 tokenId = totalSupply;
        ownerOf[tokenId] = _to;
        tokensOfOwner[_to].push(tokenId);
        tokenIndex[tokenId] = tokensOfOwner[_to].length - 1;
        emit Mint(_to, tokenId);
        emit Transfer(address(0), _to, tokenId);
        return tokenId;
    }

    function balanceOf(address _owner) external view returns (uint256) {
        return tokensOfOwner[_owner].length;
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256) {
        return tokensOfOwner[_owner][_index];
    }

    function tokenByIndex(uint256 _index) external view returns (uint256) {
        require(_index < totalSupply);
        return _index + 1;
    }
}
