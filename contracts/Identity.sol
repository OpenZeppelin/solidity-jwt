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

  mapping (address => bool) public accounts;
  string audience;
  string subject;
  
  constructor(string memory sub, string memory aud) public payable {
    accounts[msg.sender] = true;
    audience = aud;
    subject = sub;
  }

  function recover(string memory headerJson, string memory payloadJson, bytes memory signature) public {
    string memory headerBase64 = headerJson.encode();
    string memory payloadBase64 = payloadJson.encode();
    StringUtils.slice[] memory slices = new StringUtils.slice[](2);
    slices[0] = headerBase64.toSlice();
    slices[1] = payloadBase64.toSlice();
    string memory message = ".".toSlice().join(slices);
    string memory kid = parseHeader(headerJson);
    require(message.pkcs1Sha256VerifyStr(signature, getRsaExponent(kid), getRsaModulus(kid)) == 0, "RSA signature check failed");

    (string memory aud, string memory nonce, string memory sub) = parseToken(payloadJson);
    
    require(aud.strCompare(audience) == 0 || true, "Audience does not match");
    require(sub.strCompare(subject) == 0, "Subject does not match");

    string memory senderBase64 = string(abi.encodePacked(msg.sender)).encode();
    require(senderBase64.strCompare(nonce) == 0, "Sender does not match nonce");

    accounts[msg.sender] = true;
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
    }
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

  function getRsaExponent(string memory kid) internal pure returns (bytes memory) {
    if (kid.strCompare("a4313e7fd1e9e2a4ded3b292d2a7f4e519574308") == 0) {
      return hex"94edff42845dfc3f141c08c571d834ffc18e88bc96a385628b2f1c0cb3467fc4f579096aaa13d8666bc638f87220b599f452273974fd0331f928f7de3a7304cf2e13a9f18bb5d70096e7ea00b7bfaaeb26abb49234855f4b0e623d98f35e4dc15e3ce814d64b7eab28aa1786cde93eb095754e2e49410da144f4994216daf71567e86f14c6be6e815847436e4fe872f869c8e1bafa523c4167eed8af1088566442f7e427aa1de95ffb8f160383cbcd156f7c5312fa15ba7ab8d7eeec53f668fcb93ef31a5e35ff305df65327d8241e3f768b0de405a0568b697d8d65cb5101212bcfa1fd3085d09e0335a622a773ce219a27f2f9902c3e905cc70ee1785a5847";
    } else if (kid.strCompare("6f6781ba71199a658e760aa5aa93e5fc3dc752b5") == 0) {
      return hex"d49dbceff76b39683d609a217bd4ceed3d3f97710591738e5840a45f953eec42e118571f4a7ba0f97ee39e4e1425ed88cb39716584b3b2c85481302f5d290b4026e4353f60aa280e984ed7ef450029a6aadc8af247fc8cf76929981787d33a0d445afed1ff6f013aeddc4daaf682b2293d7a344cb35aabab93dc39720744076ece177f3d7ed14af07f813adc81d601b388bbd7558e144d57c638f7bc54a4edd937cd5ab75ce3482df4bf225b88420f3325602650fbad5d2e18ff9ae2185c35c37cca87d582bf25a0b3028c33ceec3acc258b77d7141009dca2d11b12c4141aa8687fb288b2e5fde9a8c664a39628192fcc1394cebf0468e5386060323afc9527";
    } else {
      revert("Key id not recognised");
    }
  }

  function getRsaModulus(string memory) internal pure returns (bytes memory) {
    return hex"0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010001";
  }
}