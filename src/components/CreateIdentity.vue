<template>
  <div>
    <p>
      <button v-on:click="create" v-bind:disabled="this.creating">
        {{ this.creating ? 'Creating...' : 'Create an identity contract' }}
      </button>
    </p>
    <p v-if="this.identity">
      <span>Identity contract created at</span>
      <br/>
      <span>{{ this.identity.options.address }}</span>
    </p>
    <p v-if="this.identity">
      <b>Save this address!</b>
    </p>
    <p v-if="this.identity">
      Now try switching to a different address in Metamask, and heading over to the <a href="/recover">recovery</a> page, to see if you can regain access to your identity contract...
    </p>
  </div>
</template>

<script>

import { parseToken } from '../utils/jwt.js';
import { Identity } from '../utils/contracts.js';

export default {
  name: 'create-identity',
  props: {
    token: { type: String },
    address: { type: String }
  },
  data () {
    return {
      error: null,
      creating: false,
      identity: null
    }
  },
  methods: {
    create: async function () {
      this.creating = true;
      this.identity = null;
      const { payload } = parseToken(this.token);
      const identity = await Identity()
        .deploy({ arguments: [payload.sub, payload.aud, process.env.VUE_APP_JWKS_ADDRESS] })
        .send({ from: this.address, gasPrice: 10e9 });
      this.identity = identity;
      localStorage.identityAddress = identity.options.address;
      this.creating = false;
    }
  }
}
</script>

<style>
div > p {
  max-width: 600px;
  text-align: center;
  margin-left: auto;
  margin-right: auto;
}
</style>
