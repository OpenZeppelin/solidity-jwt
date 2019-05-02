<template>
  <div>
    <div id="google-signin"></div>
    <button id="google-signout" v-on:click="signOut">Sign out</button>
  </div>
</template>

<script>
import { parseToken } from '../utils/jwt';
export default {
  name: 'login',
  props: {
    onLogin: { type: Function, required: true },
    nonce: { type: String },
    forceSignin: { type: Boolean }
  },
  data () {
    return {
      error: null
    }
  },
  mounted () {
    
  },
  created () {
    gapi.load('auth2', () => {
      gapi.auth2.init({
        client_id: process.env.VUE_APP_GOOGLE_CLIENT_ID,
        ux_mode: 'popup',
        nonce: this.nonce ? Buffer.from(this.nonce.slice(2), 'hex').toString('base64').replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '') : null,
        scope: 'openid email'
      }).then(() => (
        this.forceSignin ? this.signOut() : Promise.resolve(true)
      )).then(() => {
        gapi.signin2.render('google-signin', {
          onsuccess: this.handleLogin,
          onfailure: this.handleFailure,
          longtitle: true,
          scope: 'openid email' // TODO: How to prevent google from returning all profile info?
        });
      });
    });
  },
  methods: {
    signOut: function() {
      return gapi.auth2.getAuthInstance().signOut().then(() => console.log("Signed out"));
    },
    handleFailure: function(err) {
      this.error = err;
    },
    handleLogin: function(googleUser) {
      const token = googleUser.getAuthResponse().id_token;
      console.log("Signed in", token, parseToken(token))
      this.onLogin(token);
    }
  }
}
</script>

<style>
#google-signin {
  width: 180px;
  margin: auto;
  margin-bottom: 20px;
}
</style>
