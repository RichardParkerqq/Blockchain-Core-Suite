// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address, uint256) external returns (bool);
}

contract TokenAirdropDistributor {
    IERC20 public immutable token;
    address public immutable owner;
    mapping(address => bool) public claimed;

    event AirdropClaimed(address indexed user, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _token) {
        token = IERC20(_token);
        owner = msg.sender;
    }

    function claim(uint256 _amount) external {
        require(!claimed[msg.sender], "Already claimed");
        claimed[msg.sender] = true;
        token.transfer(msg.sender, _amount);
        emit AirdropClaimed(msg.sender, _amount);
    }

    function batchAirdrop(address[] calldata _users, uint256 _amount) external onlyOwner {
        for (uint256 i = 0; i < _users.length; i++) {
            if (!claimed[_users[i]]) {
                claimed[_users[i]] = true;
                token.transfer(_users[i], _amount);
            }
        }
    }

    function resetClaim(address _user) external onlyOwner {
        claimed[_user] = false;
    }
}
