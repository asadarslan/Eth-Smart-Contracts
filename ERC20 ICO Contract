// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract ICO is ERC20 {
    address payable public owner;
    uint256 public tokenSaleStartTime;
    uint256 public tokenSaleEndTime;
    uint256 public maxPurchaseLimitPerWallet = 10000 * 10 ** decimals(); // 10,000 tokens per wallet
    uint256 public tokenPriceInDollars = 0.0001 ether; // 1 DAI = 0.0001 ETH
    uint256 public currentTokenPrice;
    uint256 public tokensSold;
    uint256 public tokensSoldAtLastPriceIncrease;

    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint8 decimals,
        uint256 _tokenSaleStartTime,
        uint256 _tokenSaleEndTime
    ) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply * 10 ** decimals);
        owner = payable(msg.sender);
        tokenSaleStartTime = _tokenSaleStartTime;
        tokenSaleEndTime = _tokenSaleEndTime;
        currentTokenPrice = tokenPriceInDollars;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function buyTokens() public payable {
        require(block.timestamp >= tokenSaleStartTime && block.timestamp <= tokenSaleEndTime, "Token sale has not started or has ended");
        require(msg.value > 0, "Amount of ETH sent must be greater than 0");
        require(tokensSold.add(msg.value.mul(1 ether).div(currentTokenPrice)) <= totalSupply().div(2), "Not enough tokens left for sale");
        require(balanceOf(msg.sender).add(msg.value.mul(1 ether).div(currentTokenPrice)) <= maxPurchaseLimitPerWallet, "Purchase exceeds maximum limit per wallet");

        uint256 amount = msg.value.mul(1 ether).div(currentTokenPrice);
        _mint(msg.sender, amount);
        tokensSold = tokensSold.add(amount);
        if (tokensSold >= totalSupply().div(2)) {
            tokensSoldAtLastPriceIncrease = tokensSold;
            currentTokenPrice = currentTokenPrice.add(currentTokenPrice.mul(5).div(100));
        }
    }

    function withdrawFunds() public onlyOwner {
        require(address(this).balance > 0, "There are no funds to withdraw");
        owner.transfer(address(this).balance);
    }

    function setTokenPriceInDollars(uint256 _tokenPriceInDollars) public onlyOwner {
        require(_tokenPriceInDollars > 0, "Token price must be greater than 0");
        tokenPriceInDollars = _tokenPriceInDollars;
        currentTokenPrice = tokenPriceInDollars;
    }

    function setMaxPurchaseLimitPerWallet(uint256 _maxPurchaseLimitPerWallet) public onlyOwner {
        require(_maxPurchaseLimitPerWallet > 0, "Maximum purchase limit per wallet must be greater than 0");
        maxPurchaseLimitPerWallet = _maxPurchaseLimitPerWallet;
    }

    function burnTokens(uint256 amount) public onlyOwner {
        _burn(msg.sender, amount);
    }

    function mintTokens(uint256 amount) public onlyOwner {
        _mint(msg.sender, amount);
    }

    function endTokenSale() public onlyOwner {
        tokenSaleEndTime = block.timestamp;
    }
}
