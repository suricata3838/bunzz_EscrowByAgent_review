//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interface/IEscrowByAgent.sol";

contract EscrowByAgent is Ownable, ReentrancyGuard, IEscrowByAgent {
  using SafeERC20 for IERC20;

  // TODO(Document): : Pool is one-time use, because isReleased is not swichable.
  struct Pool {
    address token;
    address sender;
    address recipient;
    address agent;
    uint64 createdAt;
    bool isReleased;
    uint256 amount;
  }

  // TODO(Warning): Naming is not consistent with `approveCancel()`.
  // RefundStatus leads readers to misunderstand that the actor got refunded from pool.
  // How about changing to  DidApproveCancel
  // use struct to decrease storage size
  struct RefundStatus {
    bool sender;
    bool recipient;
    bool agent;
  }

  uint256 public poolCount;
  uint96 public immutable feePercent;
  uint96 public immutable agentFeePercent;
  uint64 public immutable cancelLockTime;
  mapping(uint256 => Pool) public pools;
  mapping(uint256 => RefundStatus) public refundStatusList;

  modifier onlyAgent(uint256 _poolId) {
    require(pools[_poolId].agent == msg.sender, "not agent");
    _;
  }

  // TODO(to fix): _cancelLockDays accepts 0. 
  // Thus sender can retrieve pool's money beack to sender without receiver's acceptance.
  constructor(
    uint96 _feePercent,
    uint96 _agentFeePercent,
    uint64 _cancelLockDays
  ) {
    require(_feePercent < 10000, "feePercent invalid");
    require(_agentFeePercent < 10000, "AgentFeePercent invalid");
    feePercent = _feePercent;
    agentFeePercent = _agentFeePercent;
    cancelLockTime = _cancelLockDays * 24 * 3600;
  }

  function depositByETH(
    address _recipient,
    address _agent
  ) external payable override returns (uint256) {
    require(msg.value > 0, "amount invalid");
    require(
      _recipient != address(0x0) && _agent != address(0x0),
      "address invalid"
    );
    return _deposit(address(0x0), msg.sender, _recipient, _agent, msg.value);
  }

  function deposit(
    IERC20 _token,
    address _recipient,
    address _agent,
    uint256 _amount
  ) external override returns (uint256) {
    require(_amount > 0, "amount invalid");
    require(
      _recipient != address(0x0) && _agent != address(0x0),
      "address invalid"
    );
    _token.safeTransferFrom(msg.sender, address(this), _amount);
    return _deposit(address(_token), msg.sender, _recipient, _agent, _amount);
  }

  function _deposit(
    address _token,
    address _sender,
    address _recipient,
    address _agent,
    uint256 _amount
  ) internal returns (uint256) {
    require(
      _sender != _recipient && _sender != _agent && _recipient != _agent,
      "address invalid: same"
    );
    uint256 poolId = poolCount;
    pools[poolId] = Pool(
      _token,
      _sender,
      _recipient,
      _agent,
      uint64(block.timestamp),
      false,
      _amount
    );

    // if _token is zero address, then ETH
    emit Deposit(
      _sender,
      _recipient,
      _agent,
      _token,
      _amount,
      block.timestamp,
      poolId
    );
    ++poolCount;
    return poolId;
  }

  // Review: doing
  function release(
    uint256 _poolId
  ) external override onlyAgent(_poolId) nonReentrant returns (bool) {
    Pool memory pool = pools[_poolId];
    require(pool.amount > 0, "no money in pool");
    require(!pool.isReleased, "already released");

    uint256 fee = (pool.amount * feePercent) / 10000;
    uint256 agentFee = (pool.amount * agentFeePercent) / 10000;

    if (pool.token != address(0x0)) {
      IERC20(pool.token).safeTransfer(
        pool.recipient,
        pool.amount - fee - agentFee
      );
      IERC20(pool.token).safeTransfer(owner(), fee);
      IERC20(pool.token).safeTransfer(pool.agent, agentFee);
    } else {
      (bool sent1, ) = payable(pool.recipient).call{
        value: (pool.amount - fee - agentFee)
      }("");
      (bool sent2, ) = payable(owner()).call{value: (fee)}("");
      (bool sent3, ) = payable(pool.agent).call{value: (agentFee)}("");
      require(sent1 && sent2 && sent3, "Failed to send Ether");
    }

    pools[_poolId].isReleased = true;

    emit Release(pool.recipient, msg.sender, _poolId, pool.amount);
    return true;
  }

  // Q: Does money back to the sender's wallet?
  function cancel(
    uint256 _poolId
  ) external override nonReentrant returns (bool) {
    require(_poolId < poolCount, "poolId invalid");
    RefundStatus memory refundStatus = refundStatusList[_poolId];
    require(refundStatus.recipient || refundStatus.agent, "can't cancel");

    Pool memory pool = pools[_poolId];

    if (!refundStatus.recipient) {
      // TODO(to fix): block.time is different unit from unixtimestamp!
      require(
        block.timestamp > pool.createdAt + cancelLockTime,
        "during cancelLock"
      );
    }

    require(
      msg.sender == pool.sender || refundStatus.sender,
      "sender didn't approve"
    );
    require(pool.amount > 0 && !pool.isReleased, "no money in pool");

    if (pool.token != address(0x0)) {
      IERC20(pool.token).safeTransfer(pool.sender, pool.amount);
    } else {
      (bool sent, ) = payable(pool.sender).call{value: (pool.amount)}("");
      require(sent, "Failed to send Ether");
    }

    pools[_poolId].amount = 0;

    emit Cancel(msg.sender, pool.sender, _poolId, pool.amount);
    return true;
  }

  // TODO: Review: both of 
  function approveCancel(uint256 _poolId) external override returns (bool) {
    require(_poolId < poolCount, "poolId invalid");
    Pool memory pool = pools[_poolId];
    RefundStatus storage refundStatus = refundStatusList[_poolId];
    if (msg.sender == pool.recipient) {
      require(!refundStatus.recipient, "already done");
      refundStatus.recipient = true;
    } else if (msg.sender == pool.sender) {
      require(!refundStatus.sender, "already done");
      refundStatus.sender = true;
    } else if (msg.sender == pool.agent) {
      require(!refundStatus.agent, "already done");
      refundStatus.agent = true;
    } else {
      revert("no permission");
    }
    emit ApproveCancel(msg.sender, _poolId);
    return true;
  }

  // 
  function cancelable(uint256 _poolId) external view override returns (bool) {
    if (_poolId >= poolCount) return false;

    RefundStatus memory refundStatus = refundStatusList[_poolId];

    // {recipient:false, agent:false} returns false.
    // e.g. case1{recipient:false, agent:true, sender: ?} will pass.
    // e.g. cas2{recipient:true, agent:false, sender: ?} will pass.
    // e.g. case3{recipient:true, agent:true, sender: ?} will pass.
    if (!refundStatus.recipient && !refundStatus.agent) return false;

    Pool memory pool = pools[_poolId];


    // TODO: Incentive: sender(want to cancel) vs recipient(don't want to cancel)
    // Is this condition covered all caseS?
    if (
      // 1. sender has to acceptCancel(sender must be true).
      (msg.sender != pool.sender && !refundStatus.sender) ||

      // If cancelLockTime passes, case1{recipient:false, agent:true, sender: true} will pass.
      // CAUTION: If cancelLockTime passes, the money of recipient is able to be canceled without recipient's acceptance.
      // Example of collusion of sender and contract owner?
      // What if the cancelLockTime is configured with 0? 
      (!refundStatus.recipient &&
        block.timestamp <= pool.createdAt + cancelLockTime) ||
      (pool.amount == 0 || pool.isReleased)
    ) return false;

    return true;
  }
}