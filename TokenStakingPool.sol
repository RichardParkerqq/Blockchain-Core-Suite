// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address, address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
}

contract TokenStakingPool {
    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 rewardDebt;
    }

    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardToken;
    uint256 public rewardRate;
    uint256 public totalStaked;
    mapping(address => Stake) public userStakes;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 amount);

    constructor(address _stake, address _reward, uint256 _rate) {
        stakingToken = IERC20(_stake);
        rewardToken = IERC20(_reward);
        rewardRate = _rate;
    }

    function stake(uint256 _amount) external {
        require(_amount > 0, "Zero amount");
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        
        Stake storage s = userStakes[msg.sender];
        s.amount += _amount;
        s.startTime = block.timestamp;
        totalStaked += _amount;
        
        emit Staked(msg.sender, _amount);
    }

    function unstake(uint256 _amount) external {
        Stake storage s = userStakes[msg.sender];
        require(s.amount >= _amount, "Insufficient stake");
        
        s.amount -= _amount;
        totalStaked -= _amount;
        stakingToken.transfer(msg.sender, _amount);
        
        emit Unstaked(msg.sender, _amount);
    }

    function claimRewards() external {
        Stake storage s = userStakes[msg.sender];
        uint256 duration = block.timestamp - s.startTime;
        uint256 reward = s.amount * rewardRate * duration / 365 days;
        
        require(reward > 0, "No reward");
        rewardToken.transfer(msg.sender, reward);
        emit RewardsClaimed(msg.sender, reward);
    }

    function getUserStake(address _user) external view returns (uint256) {
        return userStakes[_user].amount;
    }
}
