// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultiSigWalletCore {
    address[] public owners;
    uint256 public requiredConfirmations;
    mapping(uint256 => mapping(address => bool)) public confirmations;
    mapping(uint256 => Transaction) public transactions;
    uint256 public txCount;

    struct Transaction {
        address to;
        uint256 value;
        bool executed;
    }

    event TransactionCreated(uint256 indexed txId);
    event Confirmed(uint256 indexed txId, address indexed owner);
    event Executed(uint256 indexed txId);

    modifier onlyOwner() {
        require(isOwner(msg.sender), "Not owner");
        _;
    }

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0 && _required <= _owners.length, "Invalid params");
        owners = _owners;
        requiredConfirmations = _required;
    }

    function isOwner(address _addr) internal view returns (bool) {
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == _addr) return true;
        }
        return false;
    }

    function createTransaction(address _to) external payable onlyOwner returns (uint256) {
        txCount++;
        transactions[txCount] = Transaction(_to, msg.value, false);
        emit TransactionCreated(txCount);
        return txCount;
    }

    function confirmTransaction(uint256 _txId) external onlyOwner {
        confirmations[_txId][msg.sender] = true;
        emit Confirmed(_txId, msg.sender);
    }

    function executeTransaction(uint256 _txId) external {
        Transaction storage txn = transactions[_txId];
        require(!txn.executed, "Executed");
        uint256 count = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            if (confirmations[_txId][owners[i]]) count++;
        }
        require(count >= requiredConfirmations, "Not enough confirmations");
        txn.executed = true;
        payable(txn.to).transfer(txn.value);
        emit Executed(_txId);
    }
}
