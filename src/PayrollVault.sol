// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./interfaces/IRebaseToken.sol";
import {RebaseToken} from "./RebaseToken.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract PayrollVault is AccessControl, ReentrancyGuard {
    // external contract interactions
    RebaseToken public immutable i_rebaseToken;
    ERC20 public immutable i_aUsdc;




    address private immutable i_employerAddress;
     uint256 public totalInterestAccrued;

    //     // Roles
    // bytes32 public constant PAYROLL_ADMIN_ROLE =
    //     keccak256("PAYROLL_ADMIN_ROLE");
    bytes32 public constant EMPLOYER_AND_STREAM_CONTROLLER_ROLE =
        keccak256("EMPLOYER_AND_STREAM_CONTROLLER_ROLE");
    bytes32 private constant MINT_AND_BURN_ROLE =
        keccak256("MINT_AND_BURN_ROLE"); // Role for minting and burning tokens (the pool and vault contracts)

    // Stream structure
    struct PayrollStream {
        address sender;
        address recipient;
        uint256 amount;
        uint256 startTime;
        bool active;
        uint256 claimedTime;
         uint256 interestRate;
    }

    // Tracking streams
    mapping(address => PayrollStream) public streams;
    mapping(address => uint256) public employerBalance;
    //events
    event Deposit(address indexed user, uint256 amount);
    event Redeem(address indexed user, uint256 amount);
    event InterestWithdrawn(address indexed employer, uint256 amount);

    // Events
    event StreamCreated(
        address indexed sender,
        address indexed recipient,
        uint256 amount
    );
    event StreamClaimed(address indexed recipient, uint256 amount);

    // Errors
    error PayrollVault__aUSDCTransferError();
    
    error PayrollVault__InvalidStream();
    error PayrollVault__StreamAlreadyExists();
    error PayrollVault__InsufficientStreamBalance();
    error PayrollVault__EmployerBalanceIsLow();
    error PayrollVault__RedeemFailed();
    error PayrollVault__InsufficientEmployerInterest();

    using SafeERC20 for IERC20;

    constructor(
        address _rebaseToken,
        address _aUsdc,
        address _employeeAddress
    ) {
        i_rebaseToken = RebaseToken(_rebaseToken);
        i_aUsdc = ERC20(_aUsdc);
        i_employerAddress = _employeeAddress;
        _grantRole(EMPLOYER_AND_STREAM_CONTROLLER_ROLE, _employeeAddress);
        _grantRole(MINT_AND_BURN_ROLE, address(this));
    }

    // allows the contract to receive rewards
    receive() external payable {}

    /**
     * @notice Create a payroll stream
     * @param _employee Address receiving the stream
     * @param _amount Total stream amount
     */
    function createStream(
        address _employee,
        uint256 _amount
    ) external onlyRole(EMPLOYER_AND_STREAM_CONTROLLER_ROLE) {
        if (streams[_employee].active) {
            revert PayrollVault__StreamAlreadyExists();
        }
        if (employerBalance[msg.sender] < _amount) {
            revert PayrollVault__EmployerBalanceIsLow();
        }

uint256 currentInterestRate = i_rebaseToken.getInterestRate();
        // Create stream
        streams[_employee] = PayrollStream({
            sender: msg.sender,
            recipient: _employee,
            amount: _amount,
            startTime: block.timestamp,
            active: true,
            claimedTime: block.timestamp,
            interestRate:currentInterestRate
        });

        employerBalance[msg.sender] -= _amount;
        // Initiate token stream
        rebaseMint(_employee, _amount, i_rebaseToken.getInterestRate());

        emit StreamCreated(msg.sender, _employee, _amount);
    }

    /**
     * @notice Allow recipient to claim their stream
     */
    function claimStream() external nonReentrant {
        PayrollStream storage stream = streams[msg.sender];

        if (!stream.active) {
            revert PayrollVault__InvalidStream();
        }

        // Calculate claimable amount
        uint256 claimableAmount = stream.amount;

        if (claimableAmount == 0) {
            revert PayrollVault__InsufficientStreamBalance();
        }

        // Update claimed amounts

        stream.claimedTime = block.timestamp;
        stream.active = false;
        // Unwrap tokens for recipient
        // i_aUsdc.unwrap(claimableAmount);

        rebaseBurn(msg.sender, stream.amount);
        emit StreamClaimed(msg.sender, claimableAmount);
    }

    function deposit(uint256 _amount) external nonReentrant {
        require(
            i_aUsdc.allowance(msg.sender, address(this)) >= _amount,
            "ERC20: transfer amount exceeds allowance"
        );
        // // Transfer tokens

        if (!i_aUsdc.transferFrom(msg.sender, address(this), _amount)) {
            revert PayrollVault__aUSDCTransferError();
        }

        // get the current interest rate tied to the deposit
        uint256 users_interestRate = i_rebaseToken.getInterestRate();

        rebaseMint(msg.sender, _amount, users_interestRate);
        employerBalance[i_employerAddress] += _amount;
        // emit event
        emit Deposit(msg.sender, _amount);
    }

    function rebaseMint(
        address _to,
        uint256 _amount,
        uint256 _interest_rate
    ) internal {
        i_rebaseToken.mint(_to, _amount, _interest_rate, MINT_AND_BURN_ROLE);
    }

    function rebaseBurn(address _from, uint256 _amount) internal {
        i_rebaseToken.burn(_from, _amount, MINT_AND_BURN_ROLE);
    }

      function withdrawInterest() external onlyRole(EMPLOYER_AND_STREAM_CONTROLLER_ROLE) nonReentrant {
        uint256 totalInterest = i_rebaseToken.getTotalAccruedInterest();
        if (totalInterest == 0) revert PayrollVault__InsufficientEmployerInterest();

        uint256 withdrawableInterest = totalInterest - totalInterestAccrued;
        totalInterestAccrued = totalInterest;

        bool success = i_aUsdc.transfer(msg.sender, withdrawableInterest);
        if (!success)  revert PayrollVault__aUSDCTransferError();
    


        emit InterestWithdrawn(msg.sender, withdrawableInterest);
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
        // uint256 users_interestRate = i_rebaseToken.getInterestRate();

        rebaseBurn(msg.sender, _amount);
        // executes redeem of the underlying asset

        if (!i_aUsdc.transferFrom(address(this), msg.sender, _amount)) {
            revert PayrollVault__RedeemFailed();
        }
        employerBalance[i_employerAddress] -= _amount;

        emit Redeem(msg.sender, _amount);
    }
}
