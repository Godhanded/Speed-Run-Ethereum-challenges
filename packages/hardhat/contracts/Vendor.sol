pragma solidity 0.8.4;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";

contract Vendor is Ownable {

  event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

  YourToken public yourToken;
  uint256 public tokensPerEth=100;

  constructor(address tokenAddress) {
    yourToken = YourToken(tokenAddress);
  }

  // ToDo: create a payable buyTokens() function:
  function buyTokens()public payable
  {
    uint256 amount=msg.value * tokensPerEth;
    yourToken.transfer(msg.sender, amount);
    emit BuyTokens(msg.sender, msg.value, amount);
  }

  // ToDo: create a withdraw() function that lets the owner withdraw ETH
  function withdraw()public onlyOwner{
    payable(msg.sender).transfer(address(this).balance);
  }

  // ToDo: create a sellTokens() function:
  function sellTokens(uint256 amount)public {
    yourToken.transferFrom(msg.sender, address(this), amount);
    (bool sent , )=payable(msg.sender).call{value: (amount/100)}("");
    require(sent, "Failed to transfer token from user to vendor");
  }

}
