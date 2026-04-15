// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ChainGasOptimizer {
    address public immutable owner;
    uint256 public gasThreshold = 100 gwei;
    mapping(address => bool) public whitelistedContracts;

    event GasThresholdUpdated(uint256 newThreshold);
    event ContractWhitelisted(address indexed contractAddr);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function updateGasThreshold(uint256 _new) external onlyOwner {
        gasThreshold = _new;
        emit GasThresholdUpdated(_new);
    }

    function whitelistContract(address _addr) external onlyOwner {
        whitelistedContracts[_addr] = true;
        emit ContractWhitelisted(_addr);
    }

    function isGasAcceptable(uint256 _gas) external view returns (bool) {
        return _gas <= gasThreshold;
    }

    function isContractAllowed(address _addr) external view returns (bool) {
        return whitelistedContracts[_addr];
    }
}
