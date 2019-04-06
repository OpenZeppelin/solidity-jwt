import Vue from 'vue'
import App from './App.vue'
// import Home from './components/Home.vue'
// import SignUp from './components/SignUp.vue'
// import Recover from './components/Recover.vue'

// Vue.config.productionTip = false

// const routes = {
//   '/': Home,
//   '/signup': SignUp,
//   '/recover': Recover
// }

// new Vue({
//   el: '#app',
//   data: {
//     currentRoute: window.location.pathname
//   },
//   computed: {
//     ViewComponent () {
//       return routes[this.currentRoute] || { template: '<p>Not Found</p>' }
//     }
//   },
//   render (h) { return h(this.ViewComponent) }
// });

new Vue({
  el: '#app',
  render: h => h(App)
})
