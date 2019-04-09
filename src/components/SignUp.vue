<template>
  <div id="app">
    <h1>Create a new identity with Google recovery</h1>
    <YourAddress :address="address" />
    <GoogleLogin :on-login="handleLogin" />
    <CreateIdentity v-if="this.address && this.token" :address="address" :token="token" />
  </div>
</template>

<script>
import CreateIdentity from './CreateIdentity.vue';
import GoogleLogin from './GoogleLogin.vue';
import YourAddress from './YourAddress.vue';

export default {
  name: 'signup',
  components: {
    GoogleLogin,
    CreateIdentity,
    YourAddress
  },
  methods: {
    handleLogin: function(token) {
      this.token = token;
      const [headerBase64, payloadBase64, signatureBase64] = token.split('.');
      const payload = JSON.parse(atob(payloadBase64));
      const { aud, sub } = payload;
    }
  },
  async mounted () {
    const [address] = await window.web3.eth.getAccounts();
    this.address = address;
  },
  data () {
    return {
      token: null,
      address: null
    }
  },
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
