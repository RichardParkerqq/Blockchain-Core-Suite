// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC721 {
    function transferFrom(address, address, uint256) external;
    function ownerOf(uint256) external view returns (address);
}

interface IERC20 {
    function transfer(address, uint256) external returns (bool);
}

contract NFTStakingRewards {
    struct StakeData {
        uint256 tokenId;
        uint256 startTime;
        address owner;
    }

    IERC721 public immutable nft;
    IERC20 public immutable reward;
    uint256 public rewardPerHour;
    mapping(uint256 => StakeData) public stakes;

    event NFTStaked(uint256 indexed tokenId, address indexed owner);
    event NFTUnstaked(uint256 indexed tokenId);
    event RewardsClaimed(address indexed user, uint256 amount);

    constructor(address _nft, address _reward, uint256 _rate) {
        nft = IERC721(_nft);
        reward = IERC20(_reward);
        rewardPerHour = _rate;
    }

    function stakeNFT(uint256 _tokenId) external {
        require(nft.ownerOf(_tokenId) == msg.sender, "Not owner");
        nft.transferFrom(msg.sender, address(this), _tokenId);
        stakes[_tokenId] = StakeData(_tokenId, block.timestamp, msg.sender);
        emit NFTStaked(_tokenId, msg.sender);
    }

    function unstakeNFT(uint256 _tokenId) external {
        StakeData storage s = stakes[_tokenId];
        require(s.owner == msg.sender, "Not owner");
        nft.transferFrom(address(this), msg.sender, _tokenId);
        delete stakes[_tokenId];
        emit NFTUnstaked(_tokenId);
    }

    function claimStakeRewards(uint256 _tokenId) external {
        StakeData storage s = stakes[_tokenId];
        require(s.owner == msg.sender, "Not owner");
        uint256 hoursStaked = (block.timestamp - s.startTime) / 3600;
        uint256 amount = hoursStaked * rewardPerHour;
        reward.transfer(msg.sender, amount);
        emit RewardsClaimed(msg.sender, amount);
    }
}
