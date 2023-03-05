## About
> one line description ← What issue does this module solve?

This is an escrow module for freelancer service operated by agents.

## Features

> style: dot bullet, content: (only) Who can do What
> Checking point: The key to work the protocol successfully is balancing each actor's power and incentive, because basically all protocol design should be a cooperative game. If not, we should fix it.

## Overview

This contract asts as an escrow agent who mediates the payment for freelancers.  

The sender deposit money for recipient and set agent for the payment. If the sender want to release the payment, then he can ask the agent to release the payment for the recipient.
Deployer will set the owner fee percent and agent fee percent. The fee percent and cancelLockTime are fixed values.

## Specification

### Actors

1. Sender: to ask Agent to transfer Sender's tokens.
2. Recipient: to get paid Sender's tokens though the contract.
3. Agent: to act as an escrow to transfer Sender's tokens to Recipient though the contract.
4. Contract deployer: to deploy this module contract. Same with the Contract owner if any `transferOwnership()` is not executed.
5. Contract owner: to have an access to execute `transferOwnership()`/`revokeOwnership()`. 

### Actor's operation

1. Sender:   
    - deposit the payment for Recipient to the contract, in order to prove Sender's commitment to pay the exact amount of money to Recipient under a certain condition.
2. Recipient:   
    - able to check the amount of payment passively stored on the contract.
3. Agent:
    - trigger the transfer of payment from Sender to Recipient.
    - get the agent fee passively on each payment transfer(`release()`) is executed.
4. Contract deployer:   
    - deploy this module contract.
    - configure the fee percent to give to both of Agent and Contract owner.   
    *CAUTION* : The gas fee to execute payment transfer(`release()`) should be much cheaper than the Agent fee. Otherwise nobody won't become Agent because they would keep losing money!
5. Contract owner:
   - get the owner fee passively on each release is executed. If Contract deployer won't transfer the ownership, deployer will be an owner.

## Use case

- the payment for freelancers.

## Sample dApp
- github repo URL

---
## Review report
- [Norika's report](https://github.com/zkitty-norika/bunzz_EscrowByAgent_review)
