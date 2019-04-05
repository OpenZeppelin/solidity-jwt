pragma solidity ^0.5.0;

contract Identity {
  mapping (address => bool) accounts;
  string audience;
  
  constructor(string memory aud) public payable {
    accounts[msg.sender] = true;
    audience = aud;
  }
}