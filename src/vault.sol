// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {aUSDCRebaseToken} from "./aUSDCRebaseToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title PayrollVault
 * @notice Manages payroll streams using wrapped aUSDC tokens
 * @dev Provides streaming and claiming functionality
 */
contract PayrollVault is AccessControl {
    using SafeERC20 for IERC20;

    // Roles
    bytes32 public constant PAYROLL_ADMIN_ROLE = keccak256("PAYROLL_ADMIN_ROLE");
    bytes32 public constant STREAM_CREATOR_ROLE = keccak256("STREAM_CREATOR_ROLE");

    // Contracts
    aUSDCRebaseToken public immutable wrappedToken;

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

    // Events
    event StreamCreated(
        address indexed sender, 
        address indexed recipient, 
        uint256 amount
    );
    event StreamClaimed(
        address indexed recipient, 
        uint256 amount
    );

    // Errors
    error PayrollVault__InvalidStream();
    error PayrollVault__StreamAlreadyExists();
    error PayrollVault__InsufficientStreamBalance();

    constructor(address _wrappedTokenAddress) {
        wrappedToken = aUSDCRebaseToken(_wrappedTokenAddress);
        
        // Setup roles
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(PAYROLL_ADMIN_ROLE, msg.sender);
        _setupRole(STREAM_CREATOR_ROLE, msg.sender);
    }

    /**
     * @notice Create a payroll stream
     * @param recipient Address receiving the stream
     * @param amount Total stream amount
     */
    function createStream(
        address recipient, 
        uint256 amount
    ) external onlyRole(STREAM_CREATOR_ROLE) {
        if (streams[recipient].active) {
            revert PayrollVault__StreamAlreadyExists();
        }

        // Create stream
        streams[recipient] = PayrollStream({
            sender: msg.sender,
            recipient: recipient,
            amount: amount,
            startTime: block.timestamp,
            active: true
        });

        // Initiate token stream
        wrappedToken.initiateStream(recipient, amount);

        emit StreamCreated(msg.sender, recipient, amount);
    }

    /**
     * @notice Allow recipient to claim their stream
     */
    function claimStream() external {
        PayrollStream storage stream = streams[msg.sender];
        
        if (!stream.active) {
            revert PayrollVault__InvalidStream();
        }

        // Calculate claimable amount
        uint256 claimableAmount = stream.amount - claimedAmounts[msg.sender];

        if (claimableAmount == 0) {
            revert PayrollVault__InsufficientStreamBalance();
        }

        // Update claimed amounts
        claimedAmounts[msg.sender] += claimableAmount;

        // Unwrap tokens for recipient
        wrappedToken.unwrap(claimableAmount);

        emit StreamClaimed(msg.sender, claimableAmount);
    }
}