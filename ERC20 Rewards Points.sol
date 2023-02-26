// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RewardsToken is ERC20, Ownable {
    uint256 public constant TOTAL_SUPPLY = 1000000000 * 10 ** decimals(); // 1 billion tokens
    uint256 public constant REWARD_RATE = 10 * 10 ** decimals(); // reward rate of 10 tokens per transaction
    uint256 public constant MAX_REWARDS_PER_DAY = 100000 * 10 ** decimals(); // max rewards per day capped at 100,000 tokens
    uint256 public lastRewardTimestamp;
    uint256 public rewardsRemainingToday;

    constructor() ERC20("Rewards Token", "RWD") {
        _mint(msg.sender, TOTAL_SUPPLY);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        uint256 reward = amount.mul(REWARD_RATE).div(10 ** decimals()); // calculate reward for transaction
        if (block.timestamp >= lastRewardTimestamp + 1 days) { // reset rewards counter at midnight UTC
            lastRewardTimestamp = block.timestamp - (block.timestamp % 1 days);
            rewardsRemainingToday = MAX_REWARDS_PER_DAY;
        }
        if (rewardsRemainingToday >= reward) { // ensure rewards cap is not exceeded
            rewardsRemainingToday = rewardsRemainingToday.sub(reward);
            _mint(msg.sender, reward);
        }
        bool success = super.transfer(to, amount);
        if (!success) { // if transfer failed, revert reward transaction
            _burn(msg.sender, reward);
            rewardsRemainingToday = rewardsRemainingToday.add(reward);
        }
        return success;
    }

    function withdrawFunds(uint256 amount) public onlyOwner {
        require(amount <= address(this).balance, "Insufficient balance");
        payable(owner()).transfer(amount);
    }
}
