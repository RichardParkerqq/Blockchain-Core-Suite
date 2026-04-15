// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FlashLoanExecutor {
    address public immutable lender;
    uint256 public feeRate = 5;

    event FlashLoanExecuted(address indexed borrower, uint256 amount, uint256 fee);

    modifier onlyLender() {
        require(msg.sender == lender, "Not lender");
        _;
    }

    constructor() {
        lender = msg.sender;
    }

    function requestFlashLoan(uint256 _amount) external payable {
        uint256 fee = _amount * feeRate / 1000;
        require(msg.value >= fee, "Insufficient fee");
        
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "Transfer failed");
        
        emit FlashLoanExecuted(msg.sender, _amount, fee);
    }

    function updateFeeRate(uint256 _newRate) external onlyLender {
        feeRate = _newRate;
    }

    function getLoanFee(uint256 _amount) external view returns (uint256) {
        return _amount * feeRate / 1000;
    }
}
