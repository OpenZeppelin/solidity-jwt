<template>
  <div id="app">
    <Home v-if="home" />
    <SignUp v-if="signup" />
    <Recover v-if="recover" />
  </div>
</template>

<script>
import Home from './components/Home.vue'
import SignUp from './components/SignUp.vue'
import Recover from './components/Recover.vue'
import Web3 from 'web3';

export default {
  name: 'app',
  components: {
    Home,
    SignUp,
    Recover,
  },
  mounted () {
    // Enable metamask
    if (!window.ethereum) {
      this.error = "Metamask is required to use this page"
    } else {
      window.ethereum.enable()
        .then(() => { window.web3 = new Web3(Web3.givenProvider) })
        .catch(err => { alert(err) });
    }
  },
  data () {
    return {
      home: window.location.pathname === '/',
      signup: window.location.pathname === '/signup',
      recover: window.location.pathname === '/recover'
    };
  }
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
