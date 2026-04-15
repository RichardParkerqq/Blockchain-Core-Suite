// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DeFiLendingEngine {
    struct Loan {
        uint256 id;
        address borrower;
        uint256 collateral;
        uint256 borrowAmount;
        uint256 dueTime;
        bool repaid;
    }

    uint256 public loanId;
    mapping(uint256 => Loan) public loans;
    mapping(address => uint256) public userCollateral;

    event LoanCreated(uint256 indexed id, address indexed borrower, uint256 amount);
    event LoanRepaid(uint256 indexed id);

    function createLoan(uint256 _borrowAmount) external payable returns (uint256) {
        require(msg.value > 0 && _borrowAmount > 0, "Invalid values");
        loanId++;
        loans[loanId] = Loan(
            loanId,
            msg.sender,
            msg.value,
            _borrowAmount,
            block.timestamp + 30 days,
            false
        );
        userCollateral[msg.sender] += msg.value;
        emit LoanCreated(loanId, msg.sender, _borrowAmount);
        return loanId;
    }

    function repayLoan(uint256 _id) external payable {
        Loan storage loan = loans[_id];
        require(loan.borrower == msg.sender && !loan.repaid, "Invalid loan");
        require(msg.value >= loan.borrowAmount, "Insufficient payment");
        loan.repaid = true;
        payable(msg.sender).transfer(loan.collateral);
        emit LoanRepaid(_id);
    }

    function getLoanDetails(uint256 _id) external view returns (Loan memory) {
        return loans[_id];
    }
}
