<template functional>
  <component
    :is="props.components.VChip"
    :color="props.tagColor(props.data)"
    outline
    small
    class="tag-indicator caption"
    v-bind="data.attrs"
    v-on="listeners"
  >
    <component :is="props.components.VAvatar" v-if="!props.isStatic">
      <component
        :is="props.components.VIcon"
        v-if="props.data.state == 'select'"
        :color="props.tagColor(props.data)"
      >
        check_circle
      </component>
      <component
        :is="props.components.VIcon"
        v-else-if="props.data.state == 'exclude'"
        color="red"
      >
        remove_circle
      </component>
      <component :is="props.components.VIcon" v-else color="grey lighten-2"
        >check_circle</component
      >
    </component>
    {{ props.data.name }}
  </component>
</template>

<script lang="ts">
import Tag from '@/models/tag'
import { VChip, VAvatar, VIcon } from 'vuetify/lib'

export default {
  name: 'TagIndicator',
  props: {
    components: {
      type: Object,
      default() {
        return { VChip, VAvatar, VIcon }
      },
    },
    data: { type: Object, required: true },
    isStatic: { type: Boolean, default: false },
    tagColor: {
      type: Function,
      default: (tag: Tag): string => {
        if (tag.categories.includes('servant')) {
          return 'green'
        } else if (tag.categories.includes('buff')) {
          return 'pink darken-1'
        } else if (tag.categories.includes('debuff')) {
          return 'blue'
        } else {
          return 'grey'
        }
      },
    },
  },
}
</script>

<style lang="scss" scoped>
.tag-indicator {
  user-select: none;
}
</style>
