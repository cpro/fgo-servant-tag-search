<template>
  <div>
    <v-tabs v-model="currentTab">
      <v-tab v-for="(cat, i) in categories" :key="i">
        {{ cat.title }}
      </v-tab>
      <v-spacer />
      <v-btn
        icon
        small
        title="すべて閉じる"
        class="ml-0"
        @click="expandAllSubcategories(false)"
      >
        <v-icon>keyboard_arrow_up</v-icon>
      </v-btn>
      <v-btn
        icon
        small
        title="すべて開く"
        class="ml-0"
        @click="expandAllSubcategories(true)"
      >
        <v-icon>keyboard_arrow_down</v-icon>
      </v-btn>
      <v-tab-item v-for="(cat, i) in categories" :key="i">
        <v-expansion-panel v-model="panel[i]" expand>
          <TagPaletteSubcategory
            v-for="subcat in subcategories[cat.category]"
            :key="subcat.category"
            :title="subcat.title"
            :category="subcat.category"
          />
        </v-expansion-panel>
      </v-tab-item>
    </v-tabs>
  </div>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator'
import TagIndicator from '@/components/TagIndicator.vue'
import TagPaletteSubcategory from '@/components/TagPaletteSubcategory.vue'
import Tag from '@/models/tag'

interface TagCategory {
  title: string
  category: string
}

@Component({
  components: {
    TagIndicator,
    TagPaletteSubcategory,
  },
})
export default class TagPalette extends Vue {
  private categories: TagCategory[] = [
    {
      title: 'サーヴァント特性',
      category: 'servant',
    },
    {
      title: '強化系',
      category: 'buff',
    },
    {
      title: '弱体系',
      category: 'debuff',
    },
    {
      title: 'その他',
      category: 'other',
    },
  ]
  private subcategories: { [key: string]: TagCategory[] } = {
    servant: [
      {
        title: 'クラス',
        category: 'servant_class',
      },
      {
        title: 'レアリティ',
        category: 'servant_rarity',
      },
      {
        title: 'カード種類',
        category: 'servant_card',
      },
      {
        title: '宝具',
        category: 'servant_noblephantasm',
      },
      {
        title: 'クラススキル',
        category: 'servant_classskill',
      },
      {
        title: '属性',
        category: 'servant_attr',
      },
      {
        title: 'その他の特性',
        category: 'servant_trait',
      },
      {
        title: '入手方法',
        category: 'servant_availability',
      },
    ],
    buff: [
      {
        title: '攻撃強化',
        category: 'buff_attack',
      },
      {
        title: 'クリティカル',
        category: 'buff_critical',
      },
      {
        title: '防御強化',
        category: 'buff_defence',
      },
      {
        title: 'NP関連',
        category: 'buff_np',
      },
      {
        title: 'スキルチャージ',
        category: 'buff_skillcharge',
      },
      {
        title: '弱体耐性アップ',
        category: 'buff_regist',
      },
      {
        title: '成功率アップ',
        category: 'buff_probability',
      },
      {
        title: '回復・弱体解除',
        category: 'buff_heal',
      },
      {
        title: '特攻ダメージ',
        category: 'buff_extradamage',
      },
    ],
    debuff: [
      {
        title: '攻撃弱体',
        category: 'debuff_attack',
      },
      {
        title: '防御弱体',
        category: 'debuff_defence',
      },
      {
        title: '敵強化対策',
        category: 'debuff_antibuff',
      },
      {
        title: '行動妨害',
        category: 'debuff_delay',
      },
      {
        title: '弱体耐性ダウン',
        category: 'debuff_regist',
      },
      {
        title: 'スリップダメージ',
        category: 'debuff_slip',
      },
      {
        title: '成功率ダウン',
        category: 'debuff_probability',
      },
    ],
    other: [
      {
        title: 'その他',
        category: 'other',
      },
    ],
  }
  private panel: boolean[][] = []
  private currentTab = 0
  private get allTags(): Tag[] {
    return this.$store.state.tags
  }
  private get buff(): Tag[] {
    return this.allTags.filter(t => t.categories.includes('buff'))
  }
  private tagsInCategory(category: string): Tag[] {
    return this.allTags.filter(t => t.categories.includes(category))
  }

  private created() {
    // タグのサブカテゴリーパネル開閉状況の初期化: 先頭のみ開く
    this.panel = this.categories.map(cat => {
      return this.subcategories[cat.category].map((_, i) => i === 0)
    })
  }

  private tagClick(tag: Tag) {
    this.$store.dispatch('toggleFilter', { tag })
  }

  private expandAllSubcategories(expand: boolean) {
    const currentPanel = this.panel[this.currentTab]
    currentPanel.splice(
      0,
      currentPanel.length,
      ...currentPanel.map(() => expand)
    )
  }
}
</script>

<style lang="scss" scoped>
#tag-palette {
  overflow-y: scroll;
  position: absolute;
  width: 50%;
  height: 100%;
  top: 0;
  right: 0;
  bottom: 0;
}
ul {
  margin: 0;
  padding: 0;
}
</style>
