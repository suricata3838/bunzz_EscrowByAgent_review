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
