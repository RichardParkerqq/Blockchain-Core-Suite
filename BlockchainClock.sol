// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BlockchainClock {
    struct TimeLock {
        uint256 unlockTime;
        address owner;
        bool unlocked;
    }

    mapping(bytes32 => TimeLock) public timeLocks;
    address public immutable owner;

    event LockCreated(bytes32 indexed id, uint256 unlockTime);
    event LockUnlocked(bytes32 indexed id);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createTimeLock(bytes32 _id, uint256 _duration) external {
        timeLocks[_id] = TimeLock(
            block.timestamp + _duration,
            msg.sender,
            false
        );
        emit LockCreated(_id, block.timestamp + _duration);
    }

    function unlockTimeLock(bytes32 _id) external {
        TimeLock storage lock = timeLocks[_id];
        require(lock.owner == msg.sender && !lock.unlocked && block.timestamp >= lock.unlockTime, "Cannot unlock");
        lock.unlocked = true;
        emit LockUnlocked(_id);
    }

    function getBlockTimestamp() external view returns (uint256) {
        return block.timestamp;
    }

    function isLockReady(bytes32 _id) external view returns (bool) {
        TimeLock storage lock = timeLocks[_id];
        return !lock.unlocked && block.timestamp >= lock.unlockTime;
    }
}
