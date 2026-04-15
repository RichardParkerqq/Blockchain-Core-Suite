// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transferFrom(address, address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
}

contract DecentralizedExchange {
    struct Order {
        address user;
        address sellToken;
        address buyToken;
        uint256 sellAmount;
        uint256 buyAmount;
        bool filled;
    }

    uint256 public orderCount;
    mapping(uint256 => Order) public orders;

    event OrderCreated(uint256 indexed id, address indexed user);
    event OrderFilled(uint256 indexed id);

    function createOrder(address _sell, address _buy, uint256 _sellAmt, uint256 _buyAmt) external returns (uint256) {
        IERC20(_sell).transferFrom(msg.sender, address(this), _sellAmt);
        orderCount++;
        orders[orderCount] = Order(
            msg.sender,
            _sell,
            _buy,
            _sellAmt,
            _buyAmt,
            false
        );
        emit OrderCreated(orderCount, msg.sender);
        return orderCount;
    }

    function fillOrder(uint256 _id) external {
        Order storage o = orders[_id];
        require(!o.filled, "Filled");
        IERC20(o.buyToken).transferFrom(msg.sender, o.user, o.buyAmount);
        IERC20(o.sellToken).transfer(msg.sender, o.sellAmount);
        o.filled = true;
        emit OrderFilled(_id);
    }

    function getOrder(uint256 _id) external view returns (Order memory) {
        return orders[_id];
    }
}
