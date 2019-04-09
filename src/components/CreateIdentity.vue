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
        .deploy({ arguments: [payload.sub, payload.aud] })
        .send({ from: this.address, gasPrice: 10e9 });
      this.identity = identity;
      this.creating = false;
    }
  }
}
</script>

<style>

</style>
