<template>
  <div id="app">
    <div v-if="!this.web3 || !this.network">
      <p>Loading...</p>
    </div>
    <div v-else-if="this.network != this.targetNetwork">
      <p>Please switch Metamask to network ID {{this.targetNetwork}} (current network is {{this.network}})</p>
    </div>
    <div v-else>
      <Home v-if="home" />
      <SignUp v-if="signup" />
      <Recover v-if="recover" />
    </div>
    <footer>
      <p>Proof of concept built by the <a href="https://openzeppelin.com" target="_blank">OpenZeppelin</a> team. Do not use in production. Read <a href="https://forum.openzeppelin.com/t/sign-in-with-google-to-your-identity-contract-for-fun-and-profit/1631" target="_blank">here</a> for more information, or check out <a href="https://github.com/OpenZeppelin/solidity-jwt" target="_blank">the code</a>.</p>
    </footer>
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
      alert("Metamask is required to use this page");
    } else {
      window.ethereum.enable()
        .then(() => { 
          window.web3 = this.web3 = new Web3(Web3.givenProvider);
          return this.web3.eth.net.getId();
        })
        .then(id => this.network = id)
        .catch(err => { alert(err) });
    }
  },
  data () {
    return {
      home: window.location.pathname === '/',
      signup: window.location.pathname === '/signup',
      recover: window.location.pathname === '/recover',
      web3: null,
      network: null,
      targetNetwork: process.env.VUE_APP_NETWORK
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

button {
  width: 180px;
  margin: auto;
  height: 36px;
}

footer {
  position: fixed;
  left: 0;
  bottom: 0;
  width: 100%;
}
</style>
