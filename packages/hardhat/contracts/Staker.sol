// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
  mapping (address => uint256) public balances;
  uint256 public constant threshold= 1 ether;
  uint256 public deadline= block.timestamp + 72 hours;
  bool private openForWithdraw = false;
  ExampleExternalContract example;

  ExampleExternalContract public exampleExternalContract;
  event Stake(address from,uint256 value);

  constructor(address exampleExternalContractAddress) public {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
  function stake()public payable {
    uint256 _amount= msg.value;
    balances[msg.sender]+= _amount;
    emit Stake(msg.sender,_amount);
  }


  // After some `deadline` allow anyone to call an `execute()` function
  //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value
 function execute()public {
   require(block.timestamp > deadline,"deadline has not reached");
   if(address(this).balance > threshold || block.timestamp > deadline){
     exampleExternalContract.complete{value: address(this).balance}();
   }else{
     openForWithdraw= true;
   }
 }

  // if the `threshold` was not met, allow everyone to call a `withdraw()` function
  function withdraw()public{
    if(openForWithdraw==true){
      uint _amount = balances[msg.sender];
      balances[msg.sender]=0;
      payable(msg.sender).transfer(_amount);
    }
  }


  // Add a `withdraw()` function to let users withdraw their balance


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
  function timeLeft()public view returns(uint256){
    if(block.timestamp >= deadline )
    {
      return (0);
    }
    else{
      while(block.timestamp < deadline){
      uint256 timeleft = deadline - block.timestamp;
      return timeleft;
      }
    }
  }


  // Add the `receive()` special function that receives eth and calls stake()
  receive()external payable{
    Staker.stake();
  }


}
