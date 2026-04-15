// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ChainAnalyticsTracker {
    struct Analytics {
        uint256 totalTransactions;
        uint256 totalVolume;
        uint256 activeUsers;
        uint256 lastUpdate;
    }

    Analytics public analytics;
    mapping(address => bool) public activeUsers;
    address public immutable owner;

    event TransactionRecorded(address indexed user, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function recordTransaction(uint256 _amount) external {
        analytics.totalTransactions++;
        analytics.totalVolume += _amount;
        analytics.lastUpdate = block.timestamp;
        
        if (!activeUsers[msg.sender]) {
            activeUsers[msg.sender] = true;
            analytics.activeUsers++;
        }
        
        emit TransactionRecorded(msg.sender, _amount);
    }

    function resetAnalytics() external onlyOwner {
        analytics = Analytics(0, 0, 0, block.timestamp);
    }

    function getAnalytics() external view returns (Analytics memory) {
        return analytics;
    }
}
