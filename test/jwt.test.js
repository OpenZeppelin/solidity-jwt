const JWTContract = artifacts.require("JWT");
require('chai').should();

contract("JWT", function([_, owner]) {

  before('deploy', async function () {
    this.instance = await JWTContract.new();
  })

  it('gets sub from jwt json', async function () {
    const actual = await this.instance.getSub('{ "name": "John Doe", "iat": 1516239022, "sub": "45642546" }');
    actual.should.eq('45642546');
  });

});