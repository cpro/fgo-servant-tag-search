<template>
  <v-card :class="{ 'mt-1': true, 'pb-3': true, owned: isOwned }">
    <v-card-title primary-title class="pb-0 pt-3" @click="show = true">
      <div>
        <div class="subheading">{{ servant.name }}</div>
        <span class="caption">
          ★{{ servant.rarity }} / {{ servant.className }}
        </span>
        <span class="ml-1 caption">
          <ServantEntryCardIndicator
            v-for="n in servant.quick"
            :key="`${servant.id}-q${n}`"
            text="Q"
          />
          <ServantEntryCardIndicator
            v-for="n in servant.arts"
            :key="`${servant.id}-a${n}`"
            text="A"
          />
          <ServantEntryCardIndicator
            v-for="n in servant.buster"
            :key="`${servant.id}-b${n}`"
            text="B"
          />
          &nbsp;
          <ServantEntryCardIndicator
            :text="servant.noblePhantasm.cardType.slice(0, 1) + '宝具'"
          />
        </span>
      </div>
      <v-spacer />
      No. {{ servant.id }}
      <v-btn icon class="mr-0" @click.stop="show = !show">
        <v-icon>{{
          show ? 'keyboard_arrow_up' : 'keyboard_arrow_down'
        }}</v-icon>
      </v-btn>
    </v-card-title>
    <v-slide-y-transition>
      <v-card-text v-if="show" class="py-0">
        <p class="caption text-xs-right pa-0 ma-0">
          Wiki :
          <a :href="servant.urlWiki1" target="_blank" class="ml-2">@wiki</a>
          <a :href="servant.urlWiki2" target="_blank" class="ml-2">wicurio</a>
        </p>
        <ServantEntryNoblePhantasm
          :data="servant.noblePhantasm"
          @tagClick="tagClick"
        />
        <v-divider />

        <div v-for="(s, i) in servant.skills" :key="`${servant.id}-skill${i}`">
          <ServantEntrySkill :data="s" :index="i + 1" @tagClick="tagClick" />
          <v-divider />
        </div>

        <div class="subheading mt-2 mb-2">
          クラススキル<span v-if="servant.classSkills.length === 0"
            >: なし</span
          >
        </div>
        <ol v-if="servant.classSkills.length > 0" class="ml-4 mb-2">
          <li
            v-for="(s, i) in servant.classSkills"
            :key="`${servant.id}-classskill${i}`"
          >
            {{ s.name }}: {{ s.description }}
          </li>
        </ol>
        <v-divider />

        <v-btn round flat color="grey" small @click="showTags = !showTags">
          <span class="caption">タグ一覧</span>
          <v-icon>{{ showTags ? 'arrow_drop_up' : 'arrow_drop_down' }}</v-icon>
        </v-btn>
        <div v-show="showTags">
          <TagIndicator
            v-for="tag in servant.tags"
            :key="tag.fullName"
            :data="tag"
            is-static
            @click="tagClick(tag)"
          />
        </div>
      </v-card-text>
    </v-slide-y-transition>
  </v-card>
</template>

<script lang="ts">
import { Component, Prop, Vue } from 'vue-property-decorator'
import Servant from '@/models/servant'
import Tag from '@/models/tag'
import TagIndicator from '@/components/TagIndicator.vue'
import ServantEntryCardIndicator from '@/components/ServantEntryCardIndicator.vue'
import ServantEntryNoblePhantasm from '@/components/ServantEntryNoblePhantasm.vue'
import ServantEntrySkill from '@/components/ServantEntrySkill.vue'

@Component({
  components: {
    TagIndicator,
    ServantEntryCardIndicator,
    ServantEntryNoblePhantasm,
    ServantEntrySkill,
  },
})
export default class ServantEntry extends Vue {
  @Prop(Object)
  private data!: Servant

  private show = false
  private showTags = false

  private get servant(): Servant {
    return this.data
  }

  private get isOwned(): boolean {
    return this.$store.state.ownedServants.includes(this.servant.id)
  }

  private tagClick(tag: Tag) {
    this.$store.dispatch('addFilter', { tag, state: 'select' })
  }
}
</script>

<style lang="scss" scoped>
// 所持状態のサーヴァントは左上角にマークする
.owned {
  &::before {
    content: '\f12c'; // mdi-check
    font-family: 'Material Design Icons';
    font-size: 14px;
    color: white;
    position: absolute;
    width: 25px;
    height: 25px;
    top: 0;
    left: 0;
    padding-left: 1px;
    border-radius: 2px 0 0 0;
    background: linear-gradient(
      135deg,
      rgba(33, 150, 243, 0.6) 50%,
      transparent 0
    );
  }
}
</style>
