pragma solidity ^0.8.0; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable{
  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);
  event SellTokens(address seller, uint256 amountOfETH, uint256 amount);

  uint256 public constant tokensPerEth = 100;
  YourToken public yourToken;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:
  function buyTokens() external payable {
        require(msg.value > 0, "Send ETH to buy tokens");
        uint256 tokensToBuy = msg.value * tokensPerEth; /// for ex. 1 eth = 100 tokens , i want 0.1 eth = 0.1 *100 = 10 tokens
        require(yourToken.balanceOf(address(this)) >= tokensToBuy, "Not enough tokens available");
        yourToken.transfer(msg.sender, tokensToBuy);//in this line the tokens are transferred
        emit BuyTokens(msg.sender, msg.value, tokensToBuy);
        //emit will give the value across the contract , used for displaying the value 
    }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw() external onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No ETH to withdraw");
        payable(msg.sender).transfer(contractBalance);
        //use any one of this code
       // require(address(this).balance > 0, "No ETH to withdraw");
        // payable(msg.sender).transfer(address(this).balance);
    }

  // ToDo: create a sellTokens(uint256 _amount) function:
   // i didnt use the underscore , it is used to differentiate which amount .
  function sellTokens(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");
        //amount is the amount of tokens
        uint256 etherToTransfer = amount / tokensPerEth;//i have 100 tokens so 100/100 = 1 eth 
        require(address(this).balance >= etherToTransfer, "Not enough ETH in contract");
        yourToken.transferFrom(msg.sender, address(this), amount);
        //token transfer from sender to the token contract and the ether is sent to sender 
        payable(msg.sender).transfer(etherToTransfer);
    }
}
