import '@mdi/font/css/materialdesignicons.css'
import Vue from 'vue'
import './plugins/vuetify'
import App from './App.vue'
import store from './store'

Vue.config.productionTip = false

const initialLoad = async () => {
  await Promise.all([
    store.dispatch('fetchServants'),
    store.dispatch('fetchTags'),
  ])
  store.dispatch('loadSelectionFromUrl')
  store.dispatch('loadOwnedServants')

  window.onpopstate = () => {
    store.commit('clearTagState')
    store.dispatch('loadSelectionFromUrl')
  }
}
initialLoad()

new Vue({
  store,
  render: h => h(App),
}).$mount('#app')
