// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";


/*
* @title RebaseToken
* @author Justice Essiel | Graph Builders DAO
* @notice This is a rebase token that incentivises users to deposit into a vault and gain interest in rewards.
* @notice The interest rate in the smart contract can only decrease 
* @notice Each will user will have their own interest rate that is the global interest rate at the time of depositing.
*/
contract RebaseToken is ERC20, Ownable, AccessControl {


      error RebaseToken__InterestRateCanOnlyDecrease(uint256 currentInterestRate, uint256 newInterestRate);

    /////////////////////
    // State Variables
    /////////////////////

    uint256 private constant PRECISION_FACTOR = 1e18; // Used to handle fixed-point calculations
    bytes32 private constant MINT_AND_BURN_ROLE = keccak256("MINT_AND_BURN_ROLE"); // Role for minting and burning tokens (the pool and vault contracts)
    mapping(address => uint256) private s_userInterestRate; // Keeps track of the interest rate of the user at the time they last deposited, bridged or were transferred tokens.
    mapping(address => uint256) private s_userLastUpdatedTimestamp; // the last time a user balance was updated to mint accrued interest.
    uint256 private s_interestRate = 5e10; // this is the global interest rate of the token - when users mint (or receive tokens via transferral), this is the interest rate they will get.

    /////////////////////
    // Events
    /////////////////////
    event InterestRateSet(uint256 newInterestRate);

    /////////////////////
    // Constructor
    /////////////////////

    constructor() ERC20("GRTRebased", "GBase") Ownable(msg.sender) { 

    }
    /////////////////////
    // Functions
    /////////////////////

    /**
     * @dev grants the mint and burn role to an address. This is only called by the protocol owner.
     * @param _address the address to grant the role to
     *
     */
    function grantMintAndBurnRole(address _address) external onlyOwner {
        _grantRole(MINT_AND_BURN_ROLE, _address);
    }


     /**
     * @dev sets the interest rate of the token. This is only called by the protocol owner.
     * @param _interestRate the new interest rate
     * @notice only allow the interest rate to decrease but we don't want it to revert in case it's the destination chain that is updating the interest rate (in which case it'll either be the same or larger so it won't update)
     *
     */
    /**
     * @notice Set the interest rate in the contract
     * @param _newInterestRate The new interest rate to set
     * @dev The interest rate can only decrease
     */

    function setInterestRate(uint256 _newInterestRate) external onlyOwner {
        // Set the interest rate
        if (_newInterestRate >= s_interestRate) {
            revert RebaseToken__InterestRateCanOnlyDecrease(s_interestRate, _newInterestRate);
        }
        s_interestRate = _newInterestRate;
        emit InterestRateSet(_newInterestRate);
    }
    
}






    