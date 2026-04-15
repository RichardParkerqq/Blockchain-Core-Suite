// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ChainRoleManager {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR");
    bytes32 public constant USER_ROLE = keccak256("USER");

    mapping(bytes32 => mapping(address => bool)) public roles;
    address public immutable owner;

    event RoleGranted(bytes32 indexed role, address indexed account);
    event RoleRevoked(bytes32 indexed role, address indexed account);

    modifier onlyAdmin() {
        require(roles[ADMIN_ROLE][msg.sender], "Not admin");
        _;
    }

    constructor() {
        owner = msg.sender;
        roles[ADMIN_ROLE][msg.sender] = true;
    }

    function grantRole(bytes32 _role, address _account) external onlyAdmin {
        roles[_role][_account] = true;
        emit RoleGranted(_role, _account);
    }

    function revokeRole(bytes32 _role, address _account) external onlyAdmin {
        roles[_role][_account] = false;
        emit RoleRevoked(_role, _account);
    }

    function hasRole(bytes32 _role, address _account) external view returns (bool) {
        return roles[_role][_account];
    }
}
