// // SPDX-License-Identifier: MIT
// pragma solidity 0.8.26;

// import {Script} from "forge-std/Script.sol";
// import {PayrollVault} from "../src/PayrollVault.sol";

// contract DepositScript is Script {
//     // Constant value to send during deposit (0.01 ETH)
//     uint256 private constant SEND_VALUE = 0.01 ether;

//     /**
//      * @notice Deposits funds to the specified vault.
//      * @param vault The address of the vault contract.
//      */
//     function depositFunds(address vault) public payable {
//         PayrollVault(payable(vault)).deposit{value: SEND_VALUE}();
//     }

//     /**
//      * @notice Runs the deposit script.
//      * @param vault The address of the vault contract.
//      */
//     function run(address vault) external payable {
//         depositFunds(vault);
//     }
// }

// contract RedeemScript is Script {
//     function redeemFunds(address vault) public {
//         // Redeem from the vault
//         PayrollVault(payable(vault)).redeem(type(uint256).max);
//     }

//     function run(address vault) external {
//         redeemFunds(vault);
//     }
// }