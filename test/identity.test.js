const Identity = artifacts.require("Identity");
require('chai').should();

contract("Identity", function([_, owner, device]) {

  before('deploy', async function () {
    this.instance = await Identity.new("1234567890", "theaudience.zeppelin.solutions", { from: owner });
  })

  it('works', async function () {
    const header = '{"alg":"RS256","typ":"JWT"}';
    const payload = '{"sub":"1234567890","name":"John Doe","iat":1516239022,"nonce":"xf30B2uPOlNXxeOVq5cLW1QJj+8","aud":"theaudience.zeppelin.solutions"}';
    
    const signatureBase64 = 'cdPjRPD3K0XaHsT-uzw5uctm-bA4WZUsLmSd9QgX36sek-VkfNIlD_W9lkm_c4zQqUQOM05QZORt7QOsJPVvp7OmZ4-nkRTquIdTt710cABhgCexvu2OCTBXQk7LmO9zJzF84v7nLCYwaHD4uhISb2gquTUaHjQuvp7YfgNDnqZXhwHfZSSuulknlQryKT8cBlqcPn0e0sX9fswYWrX-gdAuJJZZ4Bxug9TJu2Og8d6fnuHxi9ww5mAYdEyMgrOCGLdvi6fkjR5bZyQ6q415H9Tq1sRIStwqUihzof52yBCreFKpptezW59OIkkLX3jkpatoOKYZIzUtei_dUYprEQ';
    const signature = '0x' + Buffer.from(signatureBase64, 'base64').toString('hex');
    
    await this.instance.recover(header, payload, signature, { from: device });
    const deviceRegistered = await this.instance.accounts(device);
    deviceRegistered.should.be.true;
  });
});

