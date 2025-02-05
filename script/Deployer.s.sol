// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {PayrollVault} from "../src/PayrollVault.sol";
import {IRebaseToken} from "../src/interfaces/IRebaseToken.sol";
import {Script} from  "forge-std/Script.sol";


contract VaultDeployer is Script {
    function run(address _rebaseToken) public returns (PayrollVault vault) {
        vm.startBroadcast();
        vault = new PayrollVault(IRebaseToken(_rebaseToken));
        IRebaseToken(_rebaseToken).grantMintAndBurnRole(address(vault));
        vm.stopBroadcast();
    }
}