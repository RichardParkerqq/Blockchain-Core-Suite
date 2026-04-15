// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SubscriptionManager {
    struct Plan {
        uint256 price;
        uint256 duration;
        bool active;
    }

    struct Subscription {
        uint256 planId;
        uint256 startTime;
        uint256 endTime;
        bool active;
    }

    mapping(uint256 => Plan) public plans;
    mapping(address => Subscription) public subscriptions;
    uint256 public planCount;
    address public immutable owner;

    event PlanCreated(uint256 indexed id, uint256 price, uint256 duration);
    event Subscribed(address indexed user, uint256 planId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createPlan(uint256 _price, uint256 _duration) external onlyOwner returns (uint256) {
        planCount++;
        plans[planCount] = Plan(_price, _duration, true);
        emit PlanCreated(planCount, _price, _duration);
        return planCount;
    }

    function subscribe(uint256 _planId) external payable {
        Plan storage p = plans[_planId];
        require(p.active && msg.value == p.price, "Invalid plan");
        
        subscriptions[msg.sender] = Subscription(
            _planId,
            block.timestamp,
            block.timestamp + p.duration,
            true
        );
        emit Subscribed(msg.sender, _planId);
    }

    function isSubscribed(address _user) external view returns (bool) {
        Subscription storage s = subscriptions[_user];
        return s.active && block.timestamp < s.endTime;
    }
}
