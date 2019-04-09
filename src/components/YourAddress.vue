<template>
  <p v-if="this.address">
    <span>Your Ehereum adress is</span>
    <br/>
    <span>{{ this.address }}</span>
  </p>
</template>

<script>
export default {
  name: 'your-address',
  props: {
    address: String
  }
}
</script>