// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DAOProposalVoting {
    enum VoteType { AGAINST, FOR }

    struct Proposal {
        string description;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 endTime;
        bool executed;
    }

    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256 => bool)) public userVotes;

    event ProposalCreated(uint256 indexed id, string description);
    event VoteCast(uint256 indexed id, address voter, VoteType vote);

    function createProposal(string calldata _desc, uint256 _duration) external returns (uint256) {
        proposalCount++;
        proposals[proposalCount] = Proposal(
            _desc,
            0,
            0,
            block.timestamp + _duration,
            false
        );
        emit ProposalCreated(proposalCount, _desc);
        return proposalCount;
    }

    function castVote(uint256 _id, VoteType _vote) external {
        Proposal storage p = proposals[_id];
        require(block.timestamp < p.endTime && !userVotes[msg.sender][_id], "Cannot vote");
        
        userVotes[msg.sender][_id] = true;
        if (_vote == VoteType.FOR) p.forVotes++;
        else p.againstVotes++;
        
        emit VoteCast(_id, msg.sender, _vote);
    }

    function executeProposal(uint256 _id) external {
        Proposal storage p = proposals[_id];
        require(block.timestamp >= p.endTime && !p.executed, "Cannot execute");
        p.executed = true;
    }
}
