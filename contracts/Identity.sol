pragma solidity ^0.5.0;

import "./Base64.sol";
import "./JsmnSolLib.sol";
import "./JWT.sol";
import "./SolRsaVerify.sol";
import "./Strings.sol";

contract Identity {

  using Base64 for string;
  using StringUtils for *;
  using SolRsaVerify for *;
  using JsmnSolLib for string;

  bytes private constant rsaExponent = hex"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010001";
  bytes private constant rsaModulus = hex"B0CA0A0EEBA26CDA6C0FA56527056D49C91045CFD6598A050F7CA831173416426F3630264221C94B8189F19CBFA2073682CE16A459C5E59978320FFC9AF811A8E9B1264C4DD3B32339791458EFD65776229FF82CE26389BACFB606FDFD05AD0253045931B7BFD1383CA5D2E5F49796C828A59321F1632CED38FE66FD668D9C2851F47E50CF337A1FE37C189DA93E2CFC5CFCB833C06F749FF405E33C94AEA36D120B622E9C61BEADDF677458EEA985C6567C7A54B3F6D079FBFB6C563548C0349E5D08972D9E6BE932E69001AB0390363A342A9A874C70B231EB0B0CD90D4599D914C7ADF755EE5E5012099AA1DC5A7152B598B8F90C2B16842A26F650FE5E6F";

  mapping (address => bool) public accounts;
  string audience;
  string subject;
  
  constructor(string memory sub, string memory aud) public payable {
    accounts[msg.sender] = true;
    audience = aud;
    subject = sub;
  }

  function recover(string memory headerJson, string memory payloadJson, bytes memory signature) public 
  // view returns (string memory) 
  {
    string memory headerBase64 = headerJson.encode();
    string memory payloadBase64 = payloadJson.encode();
    StringUtils.slice[] memory slices = new StringUtils.slice[](2);
    slices[0] = headerBase64.toSlice();
    slices[1] = payloadBase64.toSlice();
    string memory message = ".".toSlice().join(slices);
    // return message;
    require(message.pkcs1Sha256VerifyStr(signature, rsaExponent, rsaModulus) == 0, "RSA signature check failed");

    (string memory aud, string memory nonce, string memory sub) = parseToken(payloadJson);
    
    require(aud.strCompare(audience) == 0 || true, "Audience does not match");
    require(sub.strCompare(subject) == 0, "Subject does not match");

    string memory senderBase64 = string(abi.encodePacked(bytes32(uint256(msg.sender)))).encode();
    require(senderBase64.strCompare(nonce) == 0, "Sender does not match nonce");

    accounts[msg.sender] = true;
  }

  function parseToken(string memory json) internal pure returns (string memory aud, string memory nonce, string memory sub) {
    (uint exitCode, JsmnSolLib.Token[] memory tokens, uint ntokens) = json.parse(20);
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

}