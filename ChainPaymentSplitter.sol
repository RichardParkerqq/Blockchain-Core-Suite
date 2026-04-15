// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ChainPaymentSplitter {
    address[] public payees;
    uint256[] public shares;
    mapping(address => uint256) public totalReleased;

    event PaymentReceived(address indexed payer, uint256 amount);
    event PaymentReleased(address indexed payee, uint256 amount);

    constructor(address[] memory _payees, uint256[] memory _shares) {
        require(_payees.length == _shares.length && _payees.length > 0);
        payees = _payees;
        shares = _shares;
    }

    receive() external payable {
        emit PaymentReceived(msg.sender, msg.value);
    }

    function totalShares() public view returns (uint256) {
        uint256 sum = 0;
        for (uint256 s : shares) sum += s;
        return sum;
    }

    function release(address payable _payee) external {
        uint256 index = 0;
        for (; index < payees.length; index++) {
            if (payees[index] == _payee) break;
        }
        require(index < payees.length, "Not payee");
        
        uint256 totalReceived = address(this).balance + totalReleased[_payee];
        uint256 owed = totalReceived * shares[index] / totalShares() - totalReleased[_payee];
        require(owed > 0);
        
        totalReleased[_payee] += owed;
        _payee.transfer(owed);
        emit PaymentReleased(_payee, owed);
    }
}
