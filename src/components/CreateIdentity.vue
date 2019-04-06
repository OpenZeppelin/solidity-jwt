<template>
  <div>
    <p>
      <span>Ethereum adress: </span>
      <span v-bind="address" />
    </p>
  </div>
</template>

<script>

export default {
  name: 'create-identity',
  props: {
    token: { type: String }
  },
  data () {
    return {
      address: null,
      error: null
    }
  },
  async mounted () {
    const [address] = await window.web3.eth.getAccounts();
    this.address = address;
  },
  methods: {
    
  }
}
</script>

<style>

</style>
