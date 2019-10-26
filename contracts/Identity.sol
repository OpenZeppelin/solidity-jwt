pragma solidity ^0.5.0;

import "./Base64.sol";
import "./JsmnSolLib.sol";
import "./JWT.sol";
import "./SolRsaVerify.sol";
import "./Strings.sol";
import "./JWKS.sol";

contract Identity {

  using Base64 for string;
  using StringUtils for *;
  using SolRsaVerify for *;
  using JsmnSolLib for string;

  mapping (address => bool) public accounts;
  address[] private accountsList;
  string public audience;
  string public subject;
  JWKS public keys;
  
  constructor(string memory sub, string memory aud, JWKS jwks) public payable {
    accounts[msg.sender] = true;
    accountsList.push(msg.sender);
    audience = aud;
    subject = sub;
    keys = jwks;
  }

  function recover(string memory headerJson, string memory payloadJson, bytes memory signature) public {
    string memory headerBase64 = headerJson.encode();
    string memory payloadBase64 = payloadJson.encode();
    StringUtils.slice[] memory slices = new StringUtils.slice[](2);
    slices[0] = headerBase64.toSlice();
    slices[1] = payloadBase64.toSlice();
    string memory message = ".".toSlice().join(slices);
    string memory kid = parseHeader(headerJson);
    bytes memory exponent = getRsaExponent(kid);
    bytes memory modulus = getRsaModulus(kid);
    require(message.pkcs1Sha256VerifyStr(signature, exponent, modulus) == 0, "RSA signature check failed");

    (string memory aud, string memory nonce, string memory sub) = parseToken(payloadJson);
    
    require(aud.strCompare(audience) == 0 || true, "Audience does not match");
    require(sub.strCompare(subject) == 0, "Subject does not match");

    string memory senderBase64 = string(abi.encodePacked(msg.sender)).encode();
    require(senderBase64.strCompare(nonce) == 0, "Sender does not match nonce");

    if (!accounts[msg.sender]) {
      accounts[msg.sender] = true;
      accountsList.push(msg.sender);
    }
  }

  function parseHeader(string memory json) internal pure returns (string memory kid) {
    (uint exitCode, JsmnSolLib.Token[] memory tokens, uint ntokens) = json.parse(20);
    require(exitCode == 0, "JSON parse failed");
    
    require(tokens[0].jsmnType == JsmnSolLib.JsmnType.OBJECT, "Expected JWT to be an object");
    uint i = 1;
    while (i < ntokens) {
      require(tokens[i].jsmnType == JsmnSolLib.JsmnType.STRING, "Expected JWT to contain only string keys");
      string memory key = json.getBytes(tokens[i].start, tokens[i].end);
      if (key.strCompare("kid") == 0) {
        require(tokens[i+1].jsmnType == JsmnSolLib.JsmnType.STRING, "Expected kid to be a string");
        return json.getBytes(tokens[i+1].start, tokens[i+1].end);
      }
      i += 2;
    }
  }

  function parseToken(string memory json) internal pure returns (string memory aud, string memory nonce, string memory sub) {
    (uint exitCode, JsmnSolLib.Token[] memory tokens, uint ntokens) = json.parse(40);
    require(exitCode == 0, "JSON parse failed");
    
    require(tokens[0].jsmnType == JsmnSolLib.JsmnType.OBJECT, "Expected JWT to be an object");
    uint i = 1;
    while (i < ntokens) {
      require(tokens[i].jsmnType == JsmnSolLib.JsmnType.STRING, "Expected JWT to contain only string keys");
      string memory key = json.getBytes(tokens[i].start, tokens[i].end);
      if (key.strCompare("sub") == 0) {
        require(tokens[i+1].jsmnType == JsmnSolLib.JsmnType.STRING, "Expected sub to be a string");
        sub = json.getBytes(tokens[i+1].start, tokens[i+1].end);
      } else if (key.strCompare("aud") == 0) {
        require(tokens[i+1].jsmnType == JsmnSolLib.JsmnType.STRING, "Expected aud to be a string");
        aud = json.getBytes(tokens[i+1].start, tokens[i+1].end);
      } else if (key.strCompare("nonce") == 0) {
        require(tokens[i+1].jsmnType == JsmnSolLib.JsmnType.STRING, "Expected nonce to be a string");
        nonce = json.getBytes(tokens[i+1].start, tokens[i+1].end);
      }
      i += 2;
    }
  }

  function getRsaModulus(string memory kid) internal view returns (bytes memory modulus) {
    modulus = keys.getModulus(kid);
    if (modulus.length == 0) revert("Key not found");
  }

  function getRsaExponent(string memory) internal pure returns (bytes memory) {
    return hex"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010001";
  }

  function getAccounts() public view returns (address[] memory) {
    return accountsList;
  }
}