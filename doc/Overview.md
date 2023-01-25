## Preparation to draft the document

### Who is actor?

1. Sender: to ask Agent to transfer Sender's tokens.
2. Recipient: to get paid Sender's tokens though the contract.
3. Agent: to act as an escrow to transfer Sender's tokens to Recipient though the contract.
4. Contract deployer: to deploy this module contract. Same with the Contract owner if any `transferOwnership()` is not executed.
5. Contract owner: to have an access to execute `transferOwnership()`/`revokeOwnership()`. 

### What is actor's activity on the process

1. Sender:   
    - deposit the payment for Recipient to the contract, in order to prove Sender's commitment to pay the exact amount of money to Recipient under a certain condition.
2. Recipient:   
    - get the payment passively from the contract.
3. Agent:   
    - trigger the transfer of payment from Sender to Recipient.
    - get the agent fee passively on each release is executed.
4. Contract deployer:   
    - deploy this module contract.
    - configure the fee percent to give to both of Agent and Contract owner.   
    *CAUTION* : The gas fee to execute `release()` should be much cheaper than the Agent fee. Otherwise nobody won't become Agent because they would keep losing money!
5. Contract owner:
   - get the owner fee passively on each release is executed. If Contract deployer won't transfer the ownership, deployer will be an owner.

### What control/access actors have

1. Sender:
    - Able to cancel to pay for Recipient under a certain condition.
2. Recipient:   
    - Able to cancel to pay for themselves.
3. Agent:    
    - Control to execute `release()` function.
    - Able to cancel to pay for Recipient.
4. Contract deployer:   
    - control the agent fee percent and owner fee percent.
5. Contract owner:   
    - get the owner fee every time a `Pool` is released.


## Consider scenarios

A. Collusion of Sender and Agent not to pay for Recipient

B. .....

---
## About
> one line description ← What issue does this module solve?

TBD

## Features

> style: dot bullet, content: (only) Who can do What
> Checking point: The key to work the protocol successfully is balancing each actor's power and incentive, because basically all protocol design should be a cooperative game. If not, we should fix it.

TBD

- ContractOwner creates a vesting schedule for a specific Beneficiary’s wallet address.
- Both ContractOwner and Beneficiary can release the token being vested, and transfer it to Beneficiary wallet.
- ContractOwner can revoke an existing vesting schedule.

Caution: Contract doesn't support native token such as Ether on Ethereum network.

## Use case

TBD

- As a token-sales manager of your project token:
    - This module handles token vesting schedule and token releasing for each stake-holder(e.g. investor).
    - Your project token would be bought by investors over an ico/public sale/seed phase over a period of time that is pre-calculated.

## Sample dApp
- github repo URL

---
## Review report
- [Norika's report](https://github.com/suricata3838/bunzz-Vesting-module)