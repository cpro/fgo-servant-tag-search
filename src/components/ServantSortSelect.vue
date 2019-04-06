<template>
  <span>
    <v-btn
      round
      small
      outline
      color="blue"
      style="width: 9rem"
      @click="goNextKey"
    >
      {{ sortKeyLabel }}
    </v-btn>
    <v-btn round small outline color="green" @click="desc = !desc">
      {{ desc ? '降順' : '昇順' }}
      <v-icon>{{ desc ? 'arrow_drop_down' : 'arrow_drop_up' }}</v-icon>
    </v-btn>
  </span>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator'
import { SortKeyType, sortKeys } from '@/models/servantsort'

@Component
export default class ServantSortSelect extends Vue {
  private get sortKey(): SortKeyType {
    return this.$store.state.servantSortKey
  }
  private set sortKey(val: SortKeyType) {
    this.$store.dispatch('setServantSort', { key: val, desc: this.desc })
  }

  private get desc(): boolean {
    return this.$store.state.servantSortDesc
  }
  private set desc(val: boolean) {
    this.$store.dispatch('setServantSort', { key: this.sortKey, desc: val })
  }

  private get sortKeyLabel(): string {
    const index = sortKeys.findIndex(k => k.key === this.sortKey)
    return sortKeys[index].name
  }

  private goNextKey() {
    let index = sortKeys.findIndex(k => k.key === this.sortKey)
    index = (index + 1) % sortKeys.length
    this.sortKey = sortKeys[index].key
  }
}
</script>
