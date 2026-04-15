// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ERC1155MultiToken {
    mapping(uint256 => mapping(address => uint256)) public balances;
    mapping(address => mapping(address => bool)) public isApprovedForAll;
    
    string public baseURI;
    address public immutable owner;

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(string memory _uri) {
        baseURI = _uri;
        owner = msg.sender;
    }

    function mint(address _to, uint256 _id, uint256 _amount) external onlyOwner {
        balances[_id][_to] += _amount;
        emit TransferSingle(msg.sender, address(0), _to, _id, _amount);
    }

    function mintBatch(address _to, uint256[] calldata _ids, uint256[] calldata _amounts) external onlyOwner {
        require(_ids.length == _amounts.length);
        for (uint256 i = 0; i < _ids.length; i++) {
            balances[_ids[i]][_to] += _amounts[i];
        }
        emit TransferBatch(msg.sender, address(0), _to, _ids, _amounts);
    }

    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount) external {
        require(balances[_id][_from] >= _amount);
        balances[_id][_from] -= _amount;
        balances[_id][_to] += _amount;
        emit TransferSingle(msg.sender, _from, _to, _id, _amount);
    }

    function setApprovalForAll(address _operator, bool _approved) external {
        isApprovedForAll[msg.sender][_operator] = _approved;
    }
}
