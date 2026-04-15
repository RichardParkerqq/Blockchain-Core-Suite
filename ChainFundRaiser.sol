// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ChainFundRaiser {
    struct Campaign {
        address creator;
        uint256 goal;
        uint256 raised;
        uint256 endTime;
        bool closed;
    }

    uint256 public campaignCount;
    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => mapping(address => uint256)) public donations;

    event CampaignCreated(uint256 indexed id, uint256 goal, uint256 endTime);
    event DonationReceived(uint256 indexed id, address donor, uint256 amount);

    function createCampaign(uint256 _goal, uint256 _duration) external returns (uint256) {
        campaignCount++;
        campaigns[campaignCount] = Campaign(
            msg.sender,
            _goal,
            0,
            block.timestamp + _duration,
            false
        );
        emit CampaignCreated(campaignCount, _goal, block.timestamp + _duration);
        return campaignCount;
    }

    function donate(uint256 _id) external payable {
        Campaign storage c = campaigns[_id];
        require(!c.closed && block.timestamp < c.endTime, "Campaign closed");
        donations[_id][msg.sender] += msg.value;
        c.raised += msg.value;
        emit DonationReceived(_id, msg.sender, msg.value);
    }

    function closeCampaign(uint256 _id) external {
        Campaign storage c = campaigns[_id];
        require(c.creator == msg.sender && !c.closed, "Not authorized");
        c.closed = true;
        payable(c.creator).transfer(c.raised);
    }
}
