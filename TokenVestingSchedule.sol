// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address, uint256) external returns (bool);
}

contract TokenVestingSchedule {
    struct Vesting {
        uint256 totalAmount;
        uint256 released;
        uint256 startTime;
        uint256 duration;
    }

    mapping(address => Vesting) public vestings;
    IERC20 public immutable token;
    address public immutable owner;

    event VestingCreated(address indexed beneficiary, uint256 amount);
    event TokensReleased(address indexed beneficiary, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(address _token) {
        token = IERC20(_token);
        owner = msg.sender;
    }

    function createVesting(address _beneficiary, uint256 _amount, uint256 _duration) external onlyOwner {
        require(_beneficiary != address(0) && _amount > 0);
        vestings[_beneficiary] = Vesting(
            _amount,
            0,
            block.timestamp,
            _duration
        );
        emit VestingCreated(_beneficiary, _amount);
    }

    function releaseTokens() external {
        Vesting storage v = vestings[msg.sender];
        require(v.totalAmount > 0, "No vesting");
        
        uint256 elapsed = block.timestamp - v.startTime;
        uint256 releasable = v.totalAmount * elapsed / v.duration - v.released;
        require(releasable > 0, "No tokens to release");
        
        v.released += releasable;
        token.transfer(msg.sender, releasable);
        emit TokensReleased(msg.sender, releasable);
    }

    function getReleasable(address _user) external view returns (uint256) {
        Vesting storage v = vestings[_user];
        uint256 elapsed = block.timestamp - v.startTime;
        return v.totalAmount * elapsed / v.duration - v.released;
    }
}
