// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DigitalAssetVault {
    struct VaultRecord {
        uint256 amount;
        uint256 lockTime;
        bool isLocked;
    }

    mapping(address => VaultRecord) public userVaults;
    address public immutable manager;

    event Deposited(address indexed user, uint256 amount, uint256 lockTime);
    event Unlocked(address indexed user);
    event Withdrawn(address indexed user, uint256 amount);

    constructor() {
        manager = msg.sender;
    }

    function deposit(uint256 _lockDuration) external payable {
        require(msg.value > 0, "Zero deposit");
        require(_lockDuration >= 1 hours, "Lock too short");
        
        VaultRecord storage record = userVaults[msg.sender];
        record.amount += msg.value;
        record.lockTime = block.timestamp + _lockDuration;
        record.isLocked = true;
        
        emit Deposited(msg.sender, msg.value, record.lockTime);
    }

    function unlockVault() external {
        VaultRecord storage record = userVaults[msg.sender];
        require(record.isLocked, "Not locked");
        require(block.timestamp >= record.lockTime, "Still locked");
        record.isLocked = false;
        emit Unlocked(msg.sender);
    }

    function withdraw() external {
        VaultRecord storage record = userVaults[msg.sender];
        require(!record.isLocked, "Locked");
        require(record.amount > 0, "No balance");
        
        uint256 amount = record.amount;
        record.amount = 0;
        payable(msg.sender).transfer(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function getVaultBalance(address _user) external view returns (uint256) {
        return userVaults[_user].amount;
    }
}
