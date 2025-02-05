# Rebasing Token Wrapper for aUSDC

## Overview
This project aims to solve the issue of unrealized potential yield in payroll streams by creating a rebasing token wrapper contract for aUSDC. The wrapper enables employers to stream wrapped-aUSDC at a 1:1 value while retaining access to the accrued interest.

## Functional Requirements

### Token Wrapper
- **Deposit** aUSDC into the contract to mint wrapped-aUSDC at a 1:1 ratio.
- **Burn** wrapped-aUSDC to release an equivalent amount of aUSDC to a recipient.
- **Track and withdraw interest** earned on aUSDC by the contract owner.

### Streaming Functionality
- **Allow streaming** of wrapped-aUSDC from an employer to an employee.
- **Enable employees to claim** their streams, burning wrapped-aUSDC and transferring equivalent aUSDC.

### Interest Withdrawal Mechanism
- **Employer can withdraw only the interest** accrued from aUSDC balances.

## Technical Requirements
- Written in **Solidity**, compatible with Ethereum and other EVM chains.
- Adheres to **ERC-20 standards** for token implementation.
- Efficient handling of **aUSDC's rebasing nature**.
- **Gas-efficient** design for both payroll claimants and employers.

## Execution Plan

### Technical Implementation
- Develop a **token wrapper** for aUSDC that enables tracking of rebasing yields.
- Implement **interest accounting** and withdrawal mechanisms.
- Design a **streaming function** that ensures seamless payroll distribution and claiming.
- Ensure **accurate calculations** for rebasing and interest accumulation.

### Testing
- Use **Hardhat, Foundry, or similar tools** for testing.
- Cover test scenarios including:
  - **Token minting and burning**
  - **Payroll streaming and claims**
  - **Accurate interest calculation and withdrawal**
  - **Edge cases (rebasing, interest miscalculations, security vulnerabilities)**

### Handover
- Provide **deployment scripts** and guidance for mainnet and testnet.
- Deliver clear **documentation**, including:
  - **Contract interfaces and usage instructions**
  - **Deployment and integration steps**
  - **Testing results and known limitations**

## Communication and Updates
- Regular **progress updates** shared with the DAO.
- Clear **feedback loop** for design and implementation adjustments.

## Additional Considerations
- **Security:** Protect against vulnerabilities such as reentrancy and overflows.
- **Gas Optimization:** Minimize gas costs for payroll streaming and claims.
- **Extensibility:** Build the contract in a way that allows future expansion to other yield-bearing tokens.

## Bounty Summary
- **Payout:** $2,500 USD
- **Deliverables:** Fully tested and documented smart contract(s) with deployment scripts.

### Success Criteria
✅ Accurate wrapping/unwrapping of aUSDC and wrapped-aUSDC.
✅ Functional payroll streaming and seamless claiming workflows.
✅ Employer access to accrued interest without disrupting streams.
✅ Comprehensive tests and clear documentation.
