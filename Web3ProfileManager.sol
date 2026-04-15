// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Web3ProfileManager {
    struct Profile {
        string displayName;
        string bio;
        string avatarURI;
        uint256 updateTime;
    }

    mapping(address => Profile) public profiles;
    mapping(string => address) public nameToAddress;

    event ProfileUpdated(address indexed user, string displayName);

    function setProfile(string calldata _name, string calldata _bio, string calldata _avatar) external {
        require(bytes(_name).length > 0, "Empty name");
        require(nameToAddress[_name] == address(0) || nameToAddress[_name] == msg.sender, "Name taken");
        
        if (bytes(profiles[msg.sender].displayName).length > 0) {
            delete nameToAddress[profiles[msg.sender].displayName];
        }
        
        profiles[msg.sender] = Profile(_name, _bio, _avatar, block.timestamp);
        nameToAddress[_name] = msg.sender;
        emit ProfileUpdated(msg.sender, _name);
    }

    function getProfile(address _user) external view returns (Profile memory) {
        return profiles[_user];
    }

    function resolveName(string calldata _name) external view returns (address) {
        return nameToAddress[_name];
    }
}
