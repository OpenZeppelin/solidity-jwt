<template>
  <div class="hello">
    <h1>Identity recovery via Google Sign-in</h1>
    <YourAddress :address="address" />
    <p>
      <label>Identity contract address</label>
      <br/>
      <input type="text" v-model="identityAddress" v-on:change="this.checkOwner" />
    </p>
    <p v-if="validAddresses">
      <p v-if="owned">
        Your address currently controls the identity contract. Hooray!
      </p>
      <p v-else-if="this.owned === false">
        Your address does not control the identity contract.
      </p>
    </p>
  </div>
</template>

<script>
import YourAddress from './YourAddress.vue';
import { Identity } from '../utils/contracts.js';

export default {
  name: 'recover',
  components: {
    YourAddress
  },
  data () {
    return {
      identityAddress: null,
      validAddresses: null,
      address: null,
      owned: null
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
            if (err =~ /Returned values aren't valid/) {
              return false;
            } else {
              Promise.reject(err);
            }
          });
      }
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
  width: 300px;
}
</style>
