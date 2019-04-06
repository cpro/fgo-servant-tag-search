<template>
  <div>
    <div class="mb-2">
      <div class="subheading">
        <span class="caption mr-1 font-weight-medium">
          SKILL {{ index }}
          <span v-if="upgrade" class="pink--text text--darken-1">[強化後]</span>
          :
        </span>
        {{ skill.name }}
        <v-btn round flat color="grey" small @click="showTags = !showTags">
          <span class="caption">タグ</span>
          <v-icon>{{ showTags ? 'arrow_drop_up' : 'arrow_drop_down' }}</v-icon>
        </v-btn>
      </div>
    </div>
    <v-slide-y-transition>
      <div v-show="showTags" class="pl-4">
        <TagIndicator
          v-for="tag in skill.tags"
          :key="tag.fullName"
          :data="tag"
          is-static
          @click="tagClick(tag)"
        />
      </div>
    </v-slide-y-transition>
    <div class="pl-4 mb-2">
      {{ skill.description }}
      <div class="caption">習得条件: {{ skill.unlock }}</div>
    </div>

    <div v-if="skill.upgrade" class="pl-4 mt-2">
      <v-divider />
      <ServantEntrySkill :data="skill.upgrade" :index="index" :upgrade="true" />
    </div>
  </div>
</template>

<script lang="ts">
import { Component, Prop, Emit, Vue } from 'vue-property-decorator'
import Skill from '@/models/skill'
import Tag from '@/models/tag'
import TagIndicator from '@/components/TagIndicator.vue'

@Component({
  components: {
    TagIndicator,
  },
})
export default class ServantEntrySkill extends Vue {
  @Prop(Object)
  private data!: Skill
  @Prop(Number)
  private index!: number
  @Prop({ type: Boolean, default: false })
  private upgrade!: boolean

  private showTags = false

  private get skill(): Skill {
    return this.data
  }

  @Emit('tagClick')
  private tagClick(tag: Tag) {
    return tag
  }
}
</script>

<style lang="scss" scoped></style>
