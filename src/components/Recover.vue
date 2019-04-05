<template>
  <div class="hello">
    <h1>Ethereum Identity contract recovery via Google Sign-in</h1>
    
    <p>
      <label>Identity contract address: </label>
      <input type="text" v-model="identityAddress" />
    </p>
  </div>
</template>

<script>
export default {
  name: 'recover',
  props: {
    identityAddress: String
  }
}
</script>

<style scoped>
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
