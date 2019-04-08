<template>
  <span class="share-buttons">
    <v-btn :href="twitterShareUrl" target="_blank" icon small>
      <v-icon color="grey darken-2">mdi-twitter</v-icon>
    </v-btn>
    <v-btn :href="hatebaBookmarkUrl" target="_blank" icon small>
      <v-icon color="grey darken-2">mdi-hatebu</v-icon>
    </v-btn>
  </span>
</template>

<script lang="ts">
import { Component, Vue } from 'vue-property-decorator'
import Tag from '@/models/tag'

@Component
export default class SocialButtons extends Vue {
  private get hatebaBookmarkUrl(): string {
    const url = new URL(window.location.href)
    return `//b.hatena.ne.jp/entry/${url.host}${url.pathname}`
  }

  private get selectedTags(): Tag[] {
    return this.$store.getters.selectedTags
  }
  private get excludedTags(): Tag[] {
    return this.$store.getters.excludedTags
  }

  private get twitterShareUrl(): string {
    const url = encodeURIComponent(window.location.href)
    const title = 'FGO Servant-Tag-Search'
    const hashtags = 'fgotagsearch'

    const cond = this.selectedTags
      .map(t => `+[${t.name}]`)
      .concat(this.excludedTags.map(t => `-[${t.name}]`))
      .join(' ')
    const text = encodeURIComponent(
      cond.length === 0
        ? title
        : `${
            cond.length < 100 ? cond : cond.substring(0, 97) + '...'
          } の検索結果 - ${title}`
    )
    return `//twitter.com/share?url=${url}&text=${text}&hashtags=${hashtags}`
  }
}
</script>

<style lang="scss" scoped>
.mdi-hatebu {
  &::before {
    content: 'B!';
    font-family: 'Verdana';
    font-weight: bold;
    font-size: 90%;
  }
}
.share-buttons {
  white-space: nowrap;
}
</style>
