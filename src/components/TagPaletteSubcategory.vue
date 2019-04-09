<template>
  <v-expansion-panel-content lazy>
    <template v-slot:header>
      {{ title }}
    </template>
    <v-card>
      <v-card-text class="py-0">
        <TagIndicator
          v-for="tag in tagsInCategory(category)"
          :key="tag.fullName"
          :data="tag"
          @click="tagClick(tag)"
        />
      </v-card-text>
    </v-card>
  </v-expansion-panel-content>
</template>

<script lang="ts">
import { Component, Prop, Vue } from 'vue-property-decorator'
import TagIndicator from '@/components/TagIndicator.vue'
import Tag from '@/models/tag'
import getSorter from '@/models/tagsort'

@Component({
  components: {
    TagIndicator,
  },
})
export default class TagPaletteSubcategory extends Vue {
  @Prop(String)
  private title!: string
  @Prop(String)
  private category!: string

  private get allTags(): Tag[] {
    return this.$store.state.tags
  }
  private tagsInCategory(category: string): Tag[] {
    const tags = this.allTags.filter(t => t.categories.includes(category))
    return tags.sort(getSorter(this.category))
  }

  private tagClick(tag: Tag) {
    this.$store.dispatch('toggleFilter', { tag })
  }
}
</script>

<style lang="scss" scoped>
.tag-palette-subcategory {
  position: relative;
}
h4 {
  margin: 0;
  padding: 0;
  font-size: 100%;
  font-weight: normal;
  width: 8rem;
}
ul {
  box-sizing: border-box;
  margin: -1.5rem 0 0 0;
  padding: 0 0 0 8rem;
  width: 100%;
}
</style>
