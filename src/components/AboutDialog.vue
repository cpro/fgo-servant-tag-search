<template>
  <v-dialog v-model="visible" scrollable max-width="720px" lazy>
    <v-card>
      <v-card-title class="headline">
        About: FGO Servant-Tag-Search
        <v-spacer />
        <v-btn icon round flat @click="visible = false">
          <v-icon>clear</v-icon>
        </v-btn>
      </v-card-title>
      <v-divider />
      <v-card-text>
        <h3>
          このサイトについて
        </h3>
        <p>
          FGOのサーヴァントをさまざまな条件の組み合わせで検索できるWebサービスです。
        </p>
        <h3>使い方</h3>
        <p>
          一覧に並んでいるタグをクリックすると、その条件に合うサーヴァントがリスト表示されます。
        </p>
        <ul class="mb-3">
          <li>
            <TagIndicator :data="tag1" />
            のように表示されているのがタグです。
          </li>
          <li>
            <TagIndicator :data="tag2" />
            左クリック/タップすると選択状態になり、この例ではセイバーのサーヴァントをすべて表示します。
          </li>
          <li>
            <TagIndicator :data="tag3" />
            右クリック/ロングタップすると除外条件の指定になり、この場合セイバー*以外*のサーヴァントすべてを表示します。
          </li>
          <li>
            タグを複数指定した場合は指定した全部の条件でAND検索します。
          </li>
          <li>
            指定した条件は「検索条件」欄にタグが表示されます。タグをクリックすると個別に条件解除、
            「クリア」をクリックするとすべて解除します。
          </li>
          <li>
            「所有サーヴァント管理」の画面では入手済みのサーヴァントを記録することができます。
            「所有サーヴァントで絞り込む」を選ぶと、検索結果に表示されるのが入手済みサーヴァントのみになります。
          </li>
        </ul>
        <h3>データについて</h3>
        <p>
          サーヴァントの各種データ・テキストは、すべて
          <a href="https://www9.atwiki.jp/f_go/" target="_blank">
            Fate/Grand Order @wiki
          </a>
          から取得しています。日頃データを整備されている皆様にこの場で感謝を申し上げます。
        </p>
        <p>
          タグ付けは取得したテキストを解析して全自動で行っています。
          ゲーム内テキストの表記不統一などにより取りこぼしがちょいちょいありますので、ご指摘いただけると助かります。
        </p>
        <h3>連絡先</h3>
        <p>
          バグ報告、ご意見、ご要望などは
          <a href="https://twitter.com/cpro29" target="_blank">
            Twitter @cpro29
          </a>
          までお願いします。
          <a
            href="https://github.com/cpro/fgo-servant-tag-search"
            target="_blank"
          >
            Github
          </a>
          の
          <a
            href="https://github.com/cpro/fgo-servant-tag-search/issues"
            target="_blank"
          >
            Issues
          </a>
          に投げてくださっても結構です。
        </p>
        <p>
          このサイトへのリンクに際してご連絡等は一切不要です。
        </p>
        <h3>プライバシー ポリシー</h3>
        <h4>アクセス解析</h4>
        <p>
          当サイトでは、Googleのアクセス解析ツール「Google アナリティクス」を
          使用しています。「Google アナリティクス」はトラフィックデータ収集の
          ためにCookieを使用しています。トラフィックデータは匿名で収集され、
          個人は特定されません。この機能はCookieを無効にすることで収集を
          拒否できます。詳しくは
          <a
            href="https://www.google.com/intl/ja/analytics/terms/jp.html"
            target="_blank"
          >
            Google アナリティクス利用規約
          </a>
          をご確認ください。
        </p>
        <h4>サーヴァントの入手状態は送信されません</h4>
        <p>
          「所有サーヴァント管理」で入力したサーヴァントの入手状態はブラウザーに
          記録されますが、Cookieは使用しておらず、当サイトのサーバーを含め
          どこにも送信されることはありません。
        </p>
      </v-card-text>
    </v-card>
  </v-dialog>
</template>

<script lang="ts">
import { Component, Prop, Vue } from 'vue-property-decorator'
import TagIndicator from '@/components/TagIndicator.vue'
import Tag from '@/models/tag'

@Component({
  components: {
    TagIndicator,
  },
})
export default class AboutDialog extends Vue {
  @Prop(Boolean)
  private value!: boolean

  private tag1 = new Tag('<servant>セイバー')
  private tag2 = new Tag('<servant>セイバー')
  private tag3 = new Tag('<servant>セイバー')

  private created() {
    this.tag2.state = 'select'
    this.tag3.state = 'exclude'
  }

  private get visible(): boolean {
    return this.value
  }
  private set visible(val: boolean) {
    this.$emit('input', val)
  }
}
</script>

<style lang="scss" scoped></style>
