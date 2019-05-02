<template>
  <div id="recover">
    <h1>Identity recovery via Google Sign-in</h1>
    <YourAddress :address="address" />
    <p>
      <label>Identity contract address</label>
      <br/>
      <input type="text" v-model="identityAddress" v-on:change="this.checkOwner" />
    </p>
    <div v-if="validAddresses">
      <p v-if="owned">
        Your address currently controls the identity contract. Try changing to a different metamask account and refresh the page, and then use google sign in to regain access.
      </p>
      <div v-else-if="this.owned === false">
        <p>
          Your address does not control the identity contract.
        </p>
        <GoogleLogin :nonce="this.address" :onLogin="this.recover" :forceSignin="true" />
      </div>
    </div>
  </div>
</template>

<script>
import YourAddress from './YourAddress.vue';
import GoogleLogin from './GoogleLogin.vue';
import { Identity } from '../utils/contracts.js';
import { tokenForRecovery, parseToken } from '../utils/jwt.js';

export default {
  name: 'recover',
  components: {
    YourAddress,
    GoogleLogin
  },
  data () {
    return {
      identityAddress: null,
      validAddresses: null,
      address: null,
      owned: null,
      recovering: false
    }
  },
  async mounted () {
    const [address] = await window.web3.eth.getAccounts();
    this.address = address;
  },
  methods: {
    checkOwner: async function () {
      this.validAddresses = (this.identityAddress.length === 42 && this.address);
      if (this.validAddresses) {
        console.log("Checking ownership of", this.identityAddress);
        this.owned = await Identity(this.identityAddress).methods.accounts(this.address).call()
          .catch(err => {
            if (err.match(/Returned values aren't valid/)) {
              return false;
            } else {
              Promise.reject(err);
            }
          });
      }
    },
    recover: async function (token) {
      this.recovering = true;
      const { header, payload, signature } = tokenForRecovery(token);
      console.log('Token:', parseToken(token));
      console.log('Recovering identity:', header, payload, signature);
      await Identity(this.identityAddress).methods
        .recover(header.toString(), payload.toString(), signature)
        .send({ from: this.address, gas: 6e6 });
      this.checkOwner();
      this.recovering = false;
    }
  }
}
</script>

<style scoped>
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
input {
  width: 340px;
  text-align: center;
}
#recover {
  max-width: 600px;
  margin: auto;
}
</style>
