<template>
  <div id="recover">
    <h1>Identity recovery via Google Sign-in</h1>
    <YourAddress :address="address" />
    <p>
      <label>Identity contract address</label>
      <br/>
      <input type="text" v-model="identityAddress" v-on:change="this.updateOwners" />
    </p>
    <div v-if="validAddresses">
      <p v-if="!!owners">
        Owners of the identity contract: {{ this.owners.join(', ') }}
      </p>
      <p v-if="owned">
        Your address currently <b>controls the identity contract</b>. Try changing to a different metamask account and refresh the page, and then use google sign in to regain access.
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
      identityAddress: localStorage.identityAddress || null,
      validAddresses: null,
      address: null,
      owned: null,
      owners: null,
      recovering: false
    }
  },
  async mounted () {
    const [address] = await window.web3.eth.getAccounts();
    this.address = address;
    this.updateOwners();
    if (window.ethereum) {
      this.accountsChangedSub = window.ethereum.on(
        'accountsChanged',
        (accounts) => {
          this.address = accounts[0];
          this.updateOwners();
        }
      );
    }
  },
  methods: {
    updateOwners: async function () {
      this.validAddresses = (this.identityAddress.length === 42 && this.address);
      if (this.validAddresses) {
        console.log("Checking ownership of", this.identityAddress);
        this.owned = null;
        this.owners = null;
        const identity = Identity(this.identityAddress);
        await this.checkOwner(identity);
        await this.loadAllOwners(identity);
      }
    },
    checkOwner: async function (identity) {
      this.owned = await identity.methods.accounts(this.address).call()
        .catch(err => {
          if (err.match(/Returned values aren't valid/)) {
            return false;
          } else {
            Promise.reject(err);
          }
        });
    },
    loadAllOwners: async function (identity) {
      const owners = await identity.methods.getAccounts().call();
      this.owners = owners;
    },
    recover: async function (token) {
      this.recovering = true;
      const { header, payload, signature } = tokenForRecovery(token);
      console.log('Token:', parseToken(token));
      console.log('Recovering identity:', header, payload, signature);
      await Identity(this.identityAddress).methods
        .recover(header.toString(), payload.toString(), signature)
        .send({ from: this.address, gas: 6e6 });
      this.updateOwners();
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
