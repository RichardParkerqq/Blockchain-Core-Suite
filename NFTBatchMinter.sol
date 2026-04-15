// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC721 {
    function mint(address to) external;
}

contract NFTBatchMinter {
    address public immutable nftContract;
    address public immutable owner;
    uint256 public maxPerBatch = 20;

    event BatchMinted(address indexed to, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _nft) {
        nftContract = _nft;
        owner = msg.sender;
    }

    function batchMint(address _to, uint256 _amount) external onlyOwner {
        require(_amount > 0 && _amount <= maxPerBatch, "Invalid amount");
        for (uint256 i = 0; i < _amount; i++) {
            IERC721(nftContract).mint(_to);
        }
        emit BatchMinted(_to, _amount);
    }

    function updateMaxBatch(uint256 _newMax) external onlyOwner {
        maxPerBatch = _newMax;
    }
}
