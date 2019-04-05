const Identity = artifacts.require("Identity");
require('chai').should();

contract.only("Identity", function([_, owner, device]) {

  before('deploy', async function () {
    this.instance = await Identity.new("1234567890", "theaudience.zeppelin.solutions", { from: owner });
  })

  it('works', async function () {
    const header = '{"alg":"RS256","typ":"JWT"}';
    const payload = '{"sub":"1234567890","name":"John Doe","iat":1516239022,"nonce":"xf30B2uPOlNXxeOVq5cLW1QJj+8","aud":"theaudience.zeppelin.solutions"}';
    
    const signatureBase64 = 'AGX1xExOqoa5XveFwkBpp2HaBL49EspzVRwb-bCDT2TnbzuqnUTG2malYsSSjGOt7sBlwcnXh3drQd_X0Ij5bgTfTQ8sTBN9EEltxK5G1pPfxkpfzv1zOdASRIUIgkADztpgZXUuQ46_YO-h4POG-CwrLNh6ecdtZpOAFcIyQkb6ryQT9lQNCWe6EzPVgPoddi-DOtFuxkiuyJaGlVE2dfaFhpLnOl_2mk2oFRUGMfIx201vTwcCXsvHVp_rmdyCKG8NUsbUY-pPkwqEh7IistNwuKt3hk2LRnMgZYdwV_2oSLJF2nD7sSJiVFo0I4BgpxurPzWHGX_AOZlwB0VFHg';
    const signature = '0x' + Buffer.from(signatureBase64, 'base64').toString('hex');
    
    console.log(device)
    console.log(await this.instance.recover(header, payload, signature, { from: device }));
    const deviceRegistered = await this.instance.accounts(device);
    deviceRegistered.should.be.true;
  });
});

