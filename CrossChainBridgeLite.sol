// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract CrossChainBridgeLite {
    struct BridgeTransfer {
        uint256 id;
        address sender;
        address recipient;
        uint256 amount;
        uint256 chainId;
        bool completed;
    }

    uint256 public transferId;
    address public immutable operator;
    mapping(uint256 => BridgeTransfer) public transfers;

    event TransferInitiated(uint256 indexed id, address indexed sender, uint256 chainId);
    event TransferCompleted(uint256 indexed id);

    modifier onlyOperator() {
        require(msg.sender == operator, "Not operator");
        _;
    }

    constructor() {
        operator = msg.sender;
    }

    function initiateTransfer(address _recipient, uint256 _amount, uint256 _targetChain) external payable returns (uint256) {
        require(msg.value == _amount, "Amount mismatch");
        transferId++;
        transfers[transferId] = BridgeTransfer(
            transferId,
            msg.sender,
            _recipient,
            _amount,
            _targetChain,
            false
        );
        emit TransferInitiated(transferId, msg.sender, _targetChain);
        return transferId;
    }

    function completeTransfer(uint256 _id) external onlyOperator {
        BridgeTransfer storage t = transfers[_id];
        require(t.id != 0 && !t.completed, "Invalid transfer");
        t.completed = true;
        payable(t.recipient).transfer(t.amount);
        emit TransferCompleted(_id);
    }

    function getTransfer(uint256 _id) external view returns (BridgeTransfer memory) {
        return transfers[_id];
    }
}
