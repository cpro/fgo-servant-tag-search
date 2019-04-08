<template>
  <v-app>
    <v-toolbar app>
      <v-toolbar-title class="headline">
        <span>FGO Servant-Tag-Search</span>
      </v-toolbar-title>
      <v-spacer />
      <v-btn round @click="ownedServantDialog = true">
        <v-icon>mdi-cards-outline</v-icon>
        所有サーヴァント
      </v-btn>
      <v-btn round @click="aboutDialog = true">
        <v-icon>mdi-information-outline</v-icon>
        About
      </v-btn>
      <SocialButtons />
      <OwnedServantDialog v-model="ownedServantDialog" />
      <AboutDialog v-model="aboutDialog" />
    </v-toolbar>

    <v-content>
      <ContentView />
    </v-content>
  </v-app>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator'
import ContentView from '@/components/ContentView.vue'
import OwnedServantDialog from '@/components/OwnedServantDialog.vue'
import AboutDialog from '@/components/AboutDialog.vue'
import SocialButtons from '@/components/SocialButtons.vue'

@Component({
  components: {
    ContentView,
    OwnedServantDialog,
    AboutDialog,
    SocialButtons,
  },
})
export default class App extends Vue {
  private ownedServantDialog = false
  private aboutDialog = false

  private async created() {
    await Promise.all([
      this.$store.dispatch('fetchServants'),
      this.$store.dispatch('fetchTags'),
    ])
    this.$store.dispatch('loadSelectionFromUrl')
    this.$store.dispatch('loadOwnedServants')

    window.onpopstate = () => {
      this.$store.commit('clearTagState')
      this.$store.dispatch('loadSelectionFromUrl')
    }
  }
}
</script>

<style lang="scss"></style>
