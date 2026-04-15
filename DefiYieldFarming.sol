// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address, address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
}

contract DefiYieldFarming {
    struct Farm {
        uint256 totalStaked;
        uint256 rewardPerSecond;
        uint256 startTime;
    }

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    IERC20 public stakeToken;
    IERC20 public rewardToken;
    Farm public farm;
    mapping(address => UserInfo) public users;

    event Staked(address indexed user, uint256 amount);
    event RewardsHarvested(address indexed user, uint256 amount);

    constructor(address _stake, address _reward, uint256 _rate) {
        stakeToken = IERC20(_stake);
        rewardToken = IERC20(_reward);
        farm = Farm(0, _rate, block.timestamp);
    }

    function deposit(uint256 _amount) external {
        UserInfo storage user = users[msg.sender];
        stakeToken.transferFrom(msg.sender, address(this), _amount);
        user.amount += _amount;
        farm.totalStaked += _amount;
        emit Staked(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external {
        UserInfo storage user = users[msg.sender];
        require(user.amount >= _amount);
        user.amount -= _amount;
        farm.totalStaked -= _amount;
        stakeToken.transfer(msg.sender, _amount);
    }

    function harvest() external {
        UserInfo storage user = users[msg.sender];
        uint256 pending = user.amount * (block.timestamp - farm.startTime) * farm.rewardPerSecond - user.rewardDebt;
        require(pending > 0);
        rewardToken.transfer(msg.sender, pending);
        user.rewardDebt += pending;
        emit RewardsHarvested(msg.sender, pending);
    }
}
