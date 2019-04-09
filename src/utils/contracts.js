const IdentityArtifact = require('../../build/contracts/Identity.json');

export function Identity(address) {
  const { abi, bytecode } = IdentityArtifact;
  return new window.web3.eth.Contract(abi, address, { data: bytecode })
}