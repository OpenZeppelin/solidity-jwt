<template>
  <div>
    <div id="google-signin"></div>
    <button v-on:click="signOut">Sign out</button>
  </div>
</template>

<script>

export default {
  name: 'login',
  props: {
    onLogin: { type: Function, required: true },
    nonce: { type: String }
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
        client_id: process.env.GOOGLE_CLIENT_ID,
        ux_mode: 'popup',
        nonce: this.nonce
      }).then(() => {
        gapi.signin2.render('google-signin', {
          onsuccess: this.handleLogin,
          onfailure: this.handleFailure,
          longtitle: true
        });
      });
    });
  },
  methods: {
    signOut: function() {
      gapi.auth2.getAuthInstance().signOut().then(() => console.log("Signed out"));
    },
    handleFailure: function() {
      this.error = `Please log in with your ${this.domain} user`;
    },
    handleLogin: function(googleUser) {
      const token = googleUser.getAuthResponse().id_token;
      console.log("Signed in")
      console.log(token);
      this.onLogin(token);
    }
  }
}
</script>
