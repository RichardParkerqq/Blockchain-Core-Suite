// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ChainTimelockController {
    address public immutable admin;
    uint256 public minDelay;
    mapping(bytes32 => uint256) public timestamps;

    event Scheduled(bytes32 indexed id, uint256 timestamp);
    event Executed(bytes32 indexed id);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    constructor(uint256 _delay) {
        admin = msg.sender;
        minDelay = _delay;
    }

    function schedule(bytes32 _id) external onlyAdmin {
        timestamps[_id] = block.timestamp + minDelay;
        emit Scheduled(_id, timestamps[_id]);
    }

    function execute(bytes32 _id) external onlyAdmin {
        require(block.timestamp >= timestamps[_id], "Too soon");
        timestamps[_id] = 0;
        emit Executed(_id);
    }

    function isReady(bytes32 _id) external view returns (bool) {
        return timestamps[_id] != 0 && block.timestamp >= timestamps[_id];
    }
}
