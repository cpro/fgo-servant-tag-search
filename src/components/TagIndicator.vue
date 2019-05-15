<template>
  <v-chip
    :color="tagColor"
    outline
    small
    class="tag-indicator caption"
    @click="click"
    @dblclick="dblclick"
  >
    <v-avatar v-if="!isStatic">
      <v-icon v-if="tag.state == 'select'" :color="tagColor">
        check_circle
      </v-icon>
      <v-icon v-else-if="tag.state == 'exclude'" color="red">
        remove_circle
      </v-icon>
      <v-icon v-else color="grey lighten-2">check_circle</v-icon>
    </v-avatar>
    {{ tag.name }}
  </v-chip>
</template>

<script lang="ts">
import { Component, Prop, Vue, Emit } from 'vue-property-decorator'
import Tag from '@/models/tag'

@Component
export default class TagIndicator extends Vue {
  @Prop(Object)
  private data!: Tag
  @Prop({ type: Boolean, default: false })
  private isStatic!: boolean

  private get tag(): Tag {
    return this.data
  }

  private get tagColor(): string {
    if (this.tag.categories.includes('servant')) {
      return 'green'
    } else if (this.tag.categories.includes('buff')) {
      return 'pink darken-1'
    } else if (this.tag.categories.includes('debuff')) {
      return 'blue'
    } else {
      return 'gray'
    }
  }

  @Emit()
  private click() {
    /* just pass through */
  }
  @Emit()
  private dblclick() {
    /* just pass through */
  }
}
</script>

<style lang="scss" scoped>
.tag-indicator {
  user-select: none;
}
</style>
