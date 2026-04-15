// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface INFT {
    function mint(address to) external;
}

contract NFTAirdropTool {
    address public nftContract;
    address public owner;
    mapping(address => bool) public hasClaimed;

    event AirdropClaimed(address indexed claimant);
    event NFTContractUpdated(address indexed newContract);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _nftContract) {
        owner = msg.sender;
        nftContract = _nftContract;
    }

    function setNFTContract(address _newContract) external onlyOwner {
        nftContract = _newContract;
        emit NFTContractUpdated(_newContract);
    }

    function claimAirdrop() external {
        require(!hasClaimed[msg.sender], "Already claimed");
        hasClaimed[msg.sender] = true;
        INFT(nftContract).mint(msg.sender);
        emit AirdropClaimed(msg.sender);
    }

    function batchClaim(address[] calldata _recipients) external onlyOwner {
        for (uint256 i = 0; i < _recipients.length; i++) {
            if (!hasClaimed[_recipients[i]]) {
                hasClaimed[_recipients[i]] = true;
                INFT(nftContract).mint(_recipients[i]);
            }
        }
    }

    function checkClaimStatus(address _user) external view returns (bool) {
        return hasClaimed[_user];
    }
}
