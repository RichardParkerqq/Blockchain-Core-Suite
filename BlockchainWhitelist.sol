// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BlockchainWhitelist {
    mapping(address => bool) public whitelist;
    mapping(address => bool) public blacklist;
    address public immutable manager;

    event Whitelisted(address indexed account);
    event Blacklisted(address indexed account);
    event Removed(address indexed account);

    modifier onlyManager() {
        require(msg.sender == manager, "Not manager");
        _;
    }

    constructor() {
        manager = msg.sender;
    }

    function addToWhitelist(address _account) external onlyManager {
        whitelist[_account] = true;
        blacklist[_account] = false;
        emit Whitelisted(_account);
    }

    function addToBlacklist(address _account) external onlyManager {
        blacklist[_account] = true;
        whitelist[_account] = false;
        emit Blacklisted(_account);
    }

    function removeFromLists(address _account) external onlyManager {
        whitelist[_account] = false;
        blacklist[_account] = false;
        emit Removed(_account);
    }

    function isWhitelisted(address _account) external view returns (bool) {
        return whitelist[_account];
    }

    function isBlacklisted(address _account) external view returns (bool) {
        return blacklist[_account];
    }
}
