// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ChainGovernanceCore {
    struct Proposal {
        uint256 id;
        address creator;
        string title;
        uint256 voteCount;
        uint256 startTime;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256 => bool)) public hasVoted;
    uint256 public proposalCount;
    address public immutable owner;

    event ProposalCreated(uint256 indexed id, address indexed creator, string title);
    event VoteCast(uint256 indexed id, address indexed voter);
    event ProposalExecuted(uint256 indexed id);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createProposal(string calldata _title) external returns (uint256) {
        proposalCount++;
        proposals[proposalCount] = Proposal(
            proposalCount,
            msg.sender,
            _title,
            0,
            block.timestamp,
            false
        );
        emit ProposalCreated(proposalCount, msg.sender, _title);
        return proposalCount;
    }

    function castVote(uint256 _proposalId) external {
        Proposal storage prop = proposals[_proposalId];
        require(prop.id != 0, "Proposal not found");
        require(!hasVoted[msg.sender][_proposalId], "Already voted");
        require(!prop.executed, "Already executed");
        
        hasVoted[msg.sender][_proposalId] = true;
        prop.voteCount++;
        emit VoteCast(_proposalId, msg.sender);
    }

    function executeProposal(uint256 _proposalId) external onlyOwner {
        Proposal storage prop = proposals[_proposalId];
        require(prop.id != 0, "Proposal not found");
        require(!prop.executed, "Already executed");
        prop.executed = true;
        emit ProposalExecuted(_proposalId);
    }

    function getProposal(uint256 _id) external view returns (Proposal memory) {
        return proposals[_id];
    }
}
