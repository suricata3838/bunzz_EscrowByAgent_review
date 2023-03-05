## Preparation to draft the document

### Who is actor?

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

### What control/access actors have

1. Sender:
    - Able to cancel to pay for Recipient under a certain condition.
2. Recipient:   
    - Able to cancel to pay for themselves.
3. Agent:    
    - Control to execute the payment transfer(`release()`).
    - Able to cancel to pay for Recipient.
4. Contract deployer:   
    - control the agent fee percent and owner fee percent.
5. Contract owner:   
    - get the owner fee every time a `Pool` is released.


## Consider incentive design and scenarios

#### A. Agent won't release the payment.
- Looks like Recipient has to trust Agent to execute `release()`.

Here  I can find 1 issue.
- Issue 1: what if Agent will never execute `release()`? Recipient can ask Sender to cancel the current Pool and star another deal?

#### B. Collusion of Sender and Agent not to pay for Recipient   
- Sender transferred tokens.   
- Recipient want to receive that tokens.   
- Sender is not willing to pay for Recipient. So Sender and Agent accepted to cancel this case(technically `Pool`). However they need to wait for the `cancelLocktime` has passed to force execution without Recipient's acceptance.

Here  I can find 2 issues.
- Issue 1: `cancelLocktime` must not be 0. In the case if cancelLocktime is 0, Sender and Agent can execute `cancel()` tx just after Sender deposits the token.   

- Issue 2: Is it really useful to make `cancelLocktime` immutable?

C. What else?
(Needs to discuss)
