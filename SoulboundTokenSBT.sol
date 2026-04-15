// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SoulboundTokenSBT {
    string public name;
    string public symbol;
    uint256 public tokenCount;
    
    mapping(uint256 => address) public tokenOwner;
    mapping(address => bool) public hasMinted;

    event Minted(address indexed to, uint256 indexed tokenId);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function mint() external {
        require(!hasMinted[msg.sender], "Already minted");
        tokenCount++;
        tokenOwner[tokenCount] = msg.sender;
        hasMinted[msg.sender] = true;
        emit Minted(msg.sender, tokenCount);
    }

    function ownerOf(uint256 _tokenId) external view returns (address) {
        return tokenOwner[_tokenId];
    }

    function balanceOf(address _owner) external view returns (uint256) {
        return hasMinted[_owner] ? 1 : 0;
    }
}
