// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ChainDataOracle {
    struct DataRecord {
        uint256 timestamp;
        uint256 value;
        string dataType;
        bool verified;
    }

    address public immutable oracleOwner;
    mapping(string => DataRecord) public dataRecords;
    mapping(address => bool) public validators;

    event DataUpdated(string indexed dataType, uint256 value);
    event ValidatorAdded(address indexed validator);

    modifier onlyOwner() {
        require(msg.sender == oracleOwner, "Not owner");
        _;
    }

    modifier onlyValidator() {
        require(validators[msg.sender], "Not validator");
        _;
    }

    constructor() {
        oracleOwner = msg.sender;
        validators[msg.sender] = true;
    }

    function addValidator(address _validator) external onlyOwner {
        validators[_validator] = true;
        emit ValidatorAdded(_validator);
    }

    function submitData(string calldata _type, uint256 _value) external onlyValidator {
        dataRecords[_type] = DataRecord(
            block.timestamp,
            _value,
            _type,
            true
        );
        emit DataUpdated(_type, _value);
    }

    function getData(string calldata _type) external view returns (DataRecord memory) {
        return dataRecords[_type];
    }

    function isDataValid(string calldata _type) external view returns (bool) {
        return dataRecords[_type].verified;
    }
}
