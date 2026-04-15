// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ChainRewardDistributor {
    address public immutable owner;
    mapping(address => uint256) public rewardBalances;
    uint256 public totalRewards;

    event RewardAdded(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addReward(address _user, uint256 _amount) external onlyOwner {
        rewardBalances[_user] += _amount;
        totalRewards += _amount;
        emit RewardAdded(_user, _amount);
    }

    function claimReward() external {
        uint256 amount = rewardBalances[msg.sender];
        require(amount > 0, "No reward");
        
        rewardBalances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit RewardClaimed(msg.sender, amount);
    }

    function batchDistribute(address[] calldata _users, uint256[] calldata _amounts) external onlyOwner {
        require(_users.length == _amounts.length, "Length mismatch");
        for (uint256 i = 0; i < _users.length; i++) {
            rewardBalances[_users[i]] += _amounts[i];
            totalRewards += _amounts[i];
        }
    }
}
