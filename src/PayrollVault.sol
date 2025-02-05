// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./interfaces/IRebaseToken.sol";
import {IERC20} from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";


contract PayrollVault {
    // external contract interactions 
    address public immutable i_rebaseToken;


    // Roles
    bytes32 public constant PAYROLL_ADMIN_ROLE = keccak256("PAYROLL_ADMIN_ROLE");
    bytes32 public constant STREAM_CREATOR_ROLE = keccak256("STREAM_CREATOR_ROLE");

    // Stream structure
    struct PayrollStream {
        address sender;
        address recipient;
        uint256 amount;
        uint256 startTime;
        bool active;
    }

    // Tracking streams
    mapping(address => PayrollStream) public streams;
    mapping(address => uint256) public claimedAmounts;


    //events
    event Deposit(address indexed user, uint256 amount);
    event Redeem(address indexed user, uint256 amount);

    error PayrollVault__RedeemFailed();

    constructor(address _rebaseToken, address aUsdc ) {
        i_rebaseToken = IRebaseToken(_rebaseToken);
        i_aUsdc = IERC20(aUsdc);
    }

    // allows the contract to receive rewards
    receive() external payable {}

    function deposit(
        address 
    ) external  {
        if (streams[msg.sender].active) {
            revert PayrollVault__StreamAlreadyExists();
        }

         require(allowance >= _amount, "ERC20: transfer amount exceeds allowance");
        // require(balance >= _amount, "ERC20: transfer amount exceeds balance");

        // // Transfer tokens
        require(i_aUsdc.transferFrom(_userAddress, address(this), _amount), "Transfer failed");
        i_rebaseToken.mint(msg.sender, msg.value, i_rebaseToken.getInterestRate());
        emit Deposit(msg.sender, msg.value);
    }

    /**
     * @dev redeems rebase token for the underlying asset
     * @param _amount the amount being redeemed
     *
     */
    function redeem(uint256 _amount) external {
        if (_amount == type(uint256).max) {
            _amount = i_rebaseToken.balanceOf(msg.sender);
        }
        i_rebaseToken.burn(msg.sender, _amount);
        // executes redeem of the underlying asset
        (bool success,) = payable(msg.sender).call{value: _amount}("");
        if (!success) {
            revert Vault__RedeemFailed();
        }
        emit Redeem(msg.sender, _amount);
    }
}