// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Web3AuthSystem {
    struct UserProfile {
        address wallet;
        string username;
        uint256 registerTime;
        bool isVerified;
    }

    mapping(address => UserProfile) public users;
    mapping(string => bool) public usernameTaken;
    address public admin;

    event UserRegistered(address indexed wallet, string username);
    event UserVerified(address indexed wallet);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function registerUser(string calldata _username) external {
        require(!usernameTaken[_username], "Username taken");
        require(users[msg.sender].wallet == address(0), "Already registered");
        
        usernameTaken[_username] = true;
        users[msg.sender] = UserProfile(
            msg.sender,
            _username,
            block.timestamp,
            false
        );
        emit UserRegistered(msg.sender, _username);
    }

    function verifyUser(address _user) external onlyAdmin {
        users[_user].isVerified = true;
        emit UserVerified(_user);
    }

    function getUser(address _wallet) external view returns (UserProfile memory) {
        return users[_wallet];
    }

    function checkUsername(string calldata _name) external view returns (bool) {
        return usernameTaken[_name];
    }
}
