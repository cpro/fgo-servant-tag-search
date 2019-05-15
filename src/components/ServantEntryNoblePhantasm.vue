<template>
  <div>
    <div class="mb-2">
      <div class="subheading">
        <span class="caption mr-1">
          <ServantEntryCardIndicator :text="np.cardType.slice(0, 1) + '宝具'" />
        </span>
        <ruby>
          {{ np.name }}
          <rp>（</rp><rt>{{ np.ruby }}</rt
          ><rp>）</rp>
        </ruby>
        <v-btn round flat color="grey" small @click="showTags = !showTags">
          <span class="caption">タグ</span>
          <v-icon>{{ showTags ? 'arrow_drop_up' : 'arrow_drop_down' }}</v-icon>
        </v-btn>
      </div>
    </div>
    <v-slide-y-transition>
      <div v-show="showTags" class="pl-4">
        <TagIndicator
          v-for="tag in np.tags"
          :key="tag.fullName"
          :data="tag"
          is-static
          @click="tagClick(tag)"
        />
      </div>
    </v-slide-y-transition>
    <div class="pl-4 mb-2">
      {{ np.description }}
    </div>

    <div v-if="np.upgrade" class="pl-4 mt-2">
      <v-divider />
      <div class="caption mt-2 mb-2">
        <span class="pink--text text--darken-1">
          [宝具強化]
        </span>
        {{ np.upgrade.unlock }}
      </div>
      <ServantEntryNoblePhantasm :data="np.upgrade" />
    </div>
  </div>
</template>

<script lang="ts">
import { Component, Prop, Vue, Emit } from 'vue-property-decorator'
import NoblePhantasm from '@/models/noblephantasm'
import Tag from '@/models/tag'
import TagIndicator from '@/components/TagIndicator.vue'
import ServantEntryCardIndicator from '@/components/ServantEntryCardIndicator.vue'

@Component({
  name: 'ServantEntryNoblePhantasm',
  components: {
    TagIndicator,
    ServantEntryCardIndicator,
  },
})
export default class ServantEntryNoblePhantasm extends Vue {
  @Prop(Object)
  private data!: NoblePhantasm

  private showTags = false

  private get np(): NoblePhantasm {
    return this.data
  }

  @Emit('tagClick')
  private tagClick(tag: Tag) {
    return tag
  }
}
</script>

<style lang="scss" scoped></style>
