<template>
  <div>
    <TagIndicator v-if="ownedServantFilterTag" :data="ownedServantFilterTag" />
    <TagIndicator
      v-for="tag in selectedTags"
      :key="tag.fullName"
      :data="tag"
      @click="tagClick(tag)"
    />
    <TagIndicator
      v-for="tag in excludedTags"
      :key="tag.fullName"
      :data="tag"
      @click="tagClick(tag)"
    />
  </div>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator'
import TagIndicator from '@/components/TagIndicator.vue'
import Tag from '@/models/tag'

@Component({
  components: {
    TagIndicator,
  },
})
export default class SelectedTags extends Vue {
  private get selectedTags(): Tag[] {
    return this.$store.getters.selectedTags
  }
  private get excludedTags(): Tag[] {
    return this.$store.getters.excludedTags
  }

  private get ownedServantFilter(): 'none' | 'owned' | 'notowned' {
    return this.$store.state.ownedServantFilter
  }
  private get ownedServantFilterTag(): Tag | undefined {
    if (this.ownedServantFilter === 'none') {
      return undefined
    }

    const tag = new Tag('<servant>所有サーヴァント')
    tag.state = this.ownedServantFilter === 'owned' ? 'select' : 'exclude'
    return tag
  }

  private tagClick(tag: Tag) {
    this.$store.dispatch('removeFilter', { tag })
  }
}
</script>
