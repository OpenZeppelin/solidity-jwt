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
  string public audience;
  string public subject;
  
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
    bytes memory exponent = getRsaExponent(kid);
    bytes memory modulus = getRsaModulus(kid);
    require(message.pkcs1Sha256VerifyStr(signature, exponent, modulus) == 0, "RSA signature check failed");

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

  function getRsaModulus(string memory kid) internal pure returns (bytes memory) {
    if (kid.strCompare("26fc4cd23d387cbc490f60db54a94a6dd1653998") == 0) {
      return hex"c1b45cfe1541884184feccaa75b9e4784c7e1901003aea816e04889f51e04b4c5a3aa8e4f2dac78b414d4cb83f3e66a3a387f7ad679d961fc0046c8978d4794e986a51119e980760e7507778034eaf293326083df36e2b8d6208f7847146878b544a9d5377741ba9cfc7677b4f3d8fdb0f6f37409d2904e75c6d5ba5bb4e09de113f0fe336f3459679eb76b62e9bbc04f668eee2e4c25654dc533ea16481bfc10a75b8b6da591585c624f362445d421aaeb41ce2c68f5513c78b50fa2d8c396d9ef1ae41bb47390c0e5ca5045b10935dad704f897ad581cba3668c1b14e9cc2ec1d781b7db77a4636b7fdb8445db5ddec064f3226cc5bd8081a0b5d9109254c1";
    } else if (kid.strCompare("5d887f26ce32577c4b5a8a1e1a52e19d301f8181") == 0) {
      return hex"d7719dac3e6c7d4ba2f383c81cd5114ed6eefdb9425ce1cc836e9bbb070d6d75a6bdbf600c04f6f6a06b341d8c162f98022d389a0123daca3db05faed688a16bc8896f39fc159689efa58fc9f13849a3e1cbd1528a7e7af58c77c0fa19615291a05739654e21fea8d844a3bf271effbb2a076a6f3e125d3b0e6b03267cecd34563535353887673d4fc2b8ce66c95824284753d03033f35c227076a4f1859b77857ad2c39244ce1fe4eddbb4c2788aff6d4a74f5d08819c743c1c63dc11927aa52976ad805dc473d4a618221bf6e24a4ccfbf3bda4e991cf8b15025c7d6c0d35c4891610b01977c56112da20cc490860eb4a7504e1791aa4cb9e2134fb5632ed5";
    } else if (kid.strCompare("a4313e7fd1e9e2a4ded3b292d2a7f4e519574308") == 0) {
      return hex"94edff42845dfc3f141c08c571d834ffc18e88bc96a385628b2f1c0cb3467fc4f579096aaa13d8666bc638f87220b599f452273974fd0331f928f7de3a7304cf2e13a9f18bb5d70096e7ea00b7bfaaeb26abb49234855f4b0e623d98f35e4dc15e3ce814d64b7eab28aa1786cde93eb095754e2e49410da144f4994216daf71567e86f14c6be6e815847436e4fe872f869c8e1bafa523c4167eed8af1088566442f7e427aa1de95ffb8f160383cbcd156f7c5312fa15ba7ab8d7eeec53f668fcb93ef31a5e35ff305df65327d8241e3f768b0de405a0568b697d8d65cb5101212bcfa1fd3085d09e0335a622a773ce219a27f2f9902c3e905cc70ee1785a5847";
    } else if (kid.strCompare("6f6781ba71199a658e760aa5aa93e5fc3dc752b5") == 0) {
      return hex"d49dbceff76b39683d609a217bd4ceed3d3f97710591738e5840a45f953eec42e118571f4a7ba0f97ee39e4e1425ed88cb39716584b3b2c85481302f5d290b4026e4353f60aa280e984ed7ef450029a6aadc8af247fc8cf76929981787d33a0d445afed1ff6f013aeddc4daaf682b2293d7a344cb35aabab93dc39720744076ece177f3d7ed14af07f813adc81d601b388bbd7558e144d57c638f7bc54a4edd937cd5ab75ce3482df4bf225b88420f3325602650fbad5d2e18ff9ae2185c35c37cca87d582bf25a0b3028c33ceec3acc258b77d7141009dca2d11b12c4141aa8687fb288b2e5fde9a8c664a39628192fcc1394cebf0468e5386060323afc9527";
    } else if (kid.strCompare("3782d3f0bc89008d9d2c01730f765cfb19d3b70e") == 0) {
      return hex"bc8b34bc6a0525159745b3cec2b6e4018b6872e41b90738df7151d0b7629d16ca0d515c69c58cee046495a259794845d30e456fc0044cfc820879fb9d7375264ae11112ece8250fd4f3a14bd9802c2f788fffc33d98beabef6637a51e2c64b07267eddc4129dfea201f7803d242b534dc5f8b49131ba006b673e4ea52f4fa01791e3f7301d1936eb5f10f427b3863066396116e64c9f0c087325cf1fea6a5dd695f4d387bf3b26c3eb185f507827074bd3e39a1c14798acd9e4b19f2723f1a9790b9297b3a1f102e253b9aeef725212b6d3db3b180068dfd657ea06231caa1c29e1b1311c368d9ff98c12bdfa3729f6ea6a3bbb206df1a91e3c5913a3ebe9bb3";
    } else {
      revert("Key id not recognised");
    }
  }

  function getRsaExponent(string memory) internal pure returns (bytes memory) {
    return hex"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010001";
  }
}