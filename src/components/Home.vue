<template>
  <div id="app">
    <h2>
      <a href="/signup">Create a new identity</a>
      |
      <a href="/recover">Recover an identity</a>
    </h2>
    <div v-bind="error"></div>
  </div>
</template>

<script>
export default {
  name: 'home',
  data () {
    return {
      error: ""
    }
  },
  created: function() {
    if (!window.ethereum) {
      this.error = "Metamask is required to use this page"
    } else {
      window.ethereum.enable().catch(err => { this.error = err });
    }
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
