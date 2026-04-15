// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PrivacyTransactionShield {
    struct PrivateTx {
        bytes32 hash;
        address sender;
        uint256 timestamp;
        bool processed;
    }

    mapping(bytes32 => PrivateTx) public transactions;
    address public immutable operator;

    event PrivateTxSubmitted(bytes32 indexed txHash, address indexed sender);
    event PrivateTxProcessed(bytes32 indexed txHash);

    modifier onlyOperator() {
        require(msg.sender == operator, "Not operator");
        _;
    }

    constructor() {
        operator = msg.sender;
    }

    function submitPrivateTransaction(bytes32 _txHash) external {
        require(transactions[_txHash].hash == 0, "Duplicate");
        transactions[_txHash] = PrivateTx(
            _txHash,
            msg.sender,
            block.timestamp,
            false
        );
        emit PrivateTxSubmitted(_txHash, msg.sender);
    }

    function processTransaction(bytes32 _txHash) external onlyOperator {
        PrivateTx storage txn = transactions[_txHash];
        require(txn.hash != 0 && !txn.processed, "Invalid tx");
        txn.processed = true;
        emit PrivateTxProcessed(_txHash);
    }

    function getTransaction(bytes32 _hash) external view returns (PrivateTx memory) {
        return transactions[_hash];
    }
}
