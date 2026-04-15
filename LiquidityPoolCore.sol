// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address, address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
}

contract LiquidityPoolCore {
    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;
    uint256 public reserveA;
    uint256 public reserveB;

    event LiquidityAdded(uint256 a, uint256 b);
    event LiquidityRemoved(uint256 a, uint256 b);
    event Swapped(address indexed user, bool aToB, uint256 amountIn, uint256 amountOut);

    constructor(address _a, address _b) {
        tokenA = IERC20(_a);
        tokenB = IERC20(_b);
    }

    function addLiquidity(uint256 _a, uint256 _b) external returns (bool) {
        tokenA.transferFrom(msg.sender, address(this), _a);
        tokenB.transferFrom(msg.sender, address(this), _b);
        reserveA += _a;
        reserveB += _b;
        emit LiquidityAdded(_a, _b);
        return true;
    }

    function removeLiquidity(uint256 _a, uint256 _b) external returns (bool) {
        require(reserveA >= _a && reserveB >= _b);
        reserveA -= _a;
        reserveB -= _b;
        tokenA.transfer(msg.sender, _a);
        tokenB.transfer(msg.sender, _b);
        emit LiquidityRemoved(_a, _b);
        return true;
    }

    function swap(bool _aToB, uint256 _amountIn) external returns (uint256) {
        uint256 amountOut;
        if (_aToB) {
            tokenA.transferFrom(msg.sender, address(this), _amountIn);
            amountOut = _amountIn * reserveB / reserveA;
            reserveA += _amountIn;
            reserveB -= amountOut;
            tokenB.transfer(msg.sender, amountOut);
        } else {
            tokenB.transferFrom(msg.sender, address(this), _amountIn);
            amountOut = _amountIn * reserveA / reserveB;
            reserveB += _amountIn;
            reserveA -= amountOut;
            tokenA.transfer(msg.sender, amountOut);
        }
        emit Swapped(msg.sender, _aToB, _amountIn, amountOut);
        return amountOut;
    }
}
