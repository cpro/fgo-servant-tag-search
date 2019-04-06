<template>
  <v-container grid-list-md fluid style="max-width:1185px">
    <v-layout align-start justify-center row wrap>
      <!-- search cond panel -->
      <v-flex xs12 md6 fill-height>
        <v-card class="mb-1">
          <v-card-title class="pt-2 pb-0">
            検索条件
            <v-spacer />
            <span class="hidden-md-and-up">
              検索結果: {{ servants.length }} 件
            </span>
            <v-btn round small outline color="pink" @click="clearButtonClick">
              <v-icon>clear</v-icon>
              クリア
            </v-btn>
          </v-card-title>
          <v-card-text id="search-result" class="pt-0 pb-2">
            <SelectedTags />
          </v-card-text>
        </v-card>

        <TagPalette />
      </v-flex>
      <!-- result panel -->
      <v-flex xs12 md6 fill-height>
        <v-card>
          <v-card-title class="py-2">
            検索結果: {{ servants.length }} 件
            <v-spacer />
            <ServantSortSelect />
          </v-card-title>
        </v-card>

        <ServantEntry
          v-for="servant in servants"
          :key="servant.id"
          :data="servant"
        />
      </v-flex>
    </v-layout>
  </v-container>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator'
import TagPalette from '@/components/TagPalette.vue'
import SelectedTags from '@/components/SelectedTags.vue'
import ServantEntry from '@/components/ServantEntry.vue'
import Servant from '@/models/servant'
import ServantSortSelect from '@/components/ServantSortSelect.vue'

@Component({
  components: {
    TagPalette,
    SelectedTags,
    ServantEntry,
    ServantSortSelect,
  },
})
export default class ContentView extends Vue {
  private get servants(): Servant[] {
    return this.$store.getters.filteredList
  }

  private clearButtonClick() {
    this.$store.dispatch('clearFilter')
  }
}
</script>

<style>
#search-result {
  height: 5.5rem;
  overflow-y: auto;
}
</style>
