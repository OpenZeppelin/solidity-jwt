const TestIdentity = artifacts.require("TestIdentity");
require('chai').should();

contract.only("Identity", function([funder, owner]) {

  const device = '0xC5fdf4076b8F3A5357c5E395ab970B5B54098Fef';

  before('fund device', async function () {
    await web3.eth.sendTransaction({ from: funder, to: device, value: 1e18 });
  });

  before('deploy', async function () {
    this.instance = await TestIdentity.new("1234567890", "theaudience.zeppelin.solutions", { from: owner });
  });

  it('works', async function () {
    const header = '{"alg":"RS256","typ":"JWT"}';
    const payload = '{"sub":"1234567890","name":"John Doe","iat":1516239022,"nonce":"xf30B2uPOlNXxeOVq5cLW1QJj-8","aud":"theaudience.zeppelin.solutions"}';
    
    const signatureBase64 = 'a2QWRyWWjx9cI1Ll9HlDkpxdJwxVha-r4UR1JmmdgbkgHqltWZsvlPZHiCp2GQbEqYDcSloorkwoWZFrSNDV9YNMrMOKl-c3Q9bylb8Y04MpcXlkU-h5DjyM5rLv6wzegP81x19suFRlWSim7U-0XsNcYwSPZmsEBoEQpBWhaWGXuF2NJ4XUUMcd4mNSiYq107-AfZWWuAHPXeJiNtcIAaVnb9m-qwwV2456qkdFRy7hwEgvoKJhgGRdzMYwXRkbP-oQG58jB_o_8ntwcdxWDEGSKCu1xIIQvIZJarpVgUq97phtDUHgIT4Q-Vc8A1k0Lu19HTy4ewoDiYJvwRP1Sw';
    const signature = '0x' + Buffer.from(signatureBase64, 'base64').toString('hex');
    
    const wasDeviceRegistered = await this.instance.accounts(device);
    wasDeviceRegistered.should.be.false;

    const tx = await this.instance.recover(header, payload, signature, { from: device, gas: 6e6 });
    console.log("    gas:", tx.receipt.gasUsed);
    const deviceRegistered = await this.instance.accounts(device);
    deviceRegistered.should.be.true;
  });

});

