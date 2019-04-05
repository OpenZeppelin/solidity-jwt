<template>
  <div id="app">
    <h1>Create a new identity with Google recovery</h1>
    <GoogleLogin :on-login="handleLogin" />
  </div>
</template>

<script>
import GoogleLogin from './GoogleLogin.vue';

export default {
  name: 'signup',
  components: {
    GoogleLogin
  },
  methods: {
    handleLogin: function(token) {

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
