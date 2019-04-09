<template>
  <v-dialog v-model="visible" scrollable max-width="800px" lazy>
    <v-card>
      <v-card-title class="title">
        所有サーヴァント管理
        <v-spacer />
        <v-btn icon round flat @click="visible = false"
          ><v-icon>clear</v-icon></v-btn
        >
      </v-card-title>
      <v-divider />
      <v-card-text>
        <v-card v-for="className in classOrder" :key="className" class="mb-2">
          <v-card-title class="subheading pb-0">
            {{ className }}
            <v-spacer />
            <span class="caption"
              >{{ getCheckedServantsCount(className) }} /
              {{ getServantsOfClass(className).length }}</span
            >
            <v-btn
              outline
              small
              class="caption"
              round
              color="green"
              @click="toggleAll(className, true)"
            >
              <v-icon>check</v-icon>
              すべてチェック
            </v-btn>
            <v-btn
              outline
              small
              class="caption"
              round
              color="pink"
              @click="toggleAll(className), false"
            >
              <v-icon>clear</v-icon>
              すべて外す
            </v-btn>
          </v-card-title>
          <v-card-text>
            <v-layout
              v-for="rarity in getRaritiesOfClass(className)"
              :key="rarity"
              row
              wrap
              align-content-start
            >
              <v-flex xs12><v-divider /></v-flex>
              <v-flex xs1>
                <v-card-text class="px-0 py-2"> ★{{ rarity }} </v-card-text>
              </v-flex>
              <v-flex xs11>
                <v-card-text class="pl-0 py-1">
                  <v-layout row wrap justify-start>
                    <v-chip
                      v-for="servant in getServantsOfClass(className, rarity)"
                      :key="servant.id"
                      color="blue"
                      outline
                      small
                      class="caption"
                      @click="toggle(servant.id)"
                    >
                      <v-avatar>
                        <v-icon
                          :color="
                            checked(servant.id) ? 'blue' : 'grey lighten-2'
                          "
                          >check_circle</v-icon
                        >
                      </v-avatar>
                      {{ servant.name }}
                    </v-chip>
                  </v-layout>
                </v-card-text>
              </v-flex>
            </v-layout>
          </v-card-text>
        </v-card>
      </v-card-text>
      <v-divider />
      <v-card-actions class="px-4">
        <v-radio-group v-model="ownedServantFilter" row>
          <v-radio value="none">
            <template v-slot:label>
              <span class="body-2">すべて対象</span>
            </template>
          </v-radio>
          <v-radio value="owned">
            <template v-slot:label>
              <span class="body-2">所有サーヴァントで絞り込む</span>
            </template>
          </v-radio>
          <v-radio value="notowned">
            <template v-slot:label>
              <span class="body-2">所有サーヴァントを除外</span>
            </template>
          </v-radio>
        </v-radio-group>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script lang="ts">
import { Component, Prop, Vue } from 'vue-property-decorator'
import { getSorter, servantClassOrder } from '@/models/servantsort'
import Servant from '@/models/servant'

@Component
export default class OwnedServantDialog extends Vue {
  @Prop(Boolean)
  private value!: boolean

  private get idList(): number[] {
    return this.$store.state.ownedServants
  }

  private get visible(): boolean {
    return this.value
  }
  private set visible(val: boolean) {
    this.$emit('input', val)
  }

  private get ownedServantFilter(): string {
    return this.$store.state.ownedServantFilter
  }
  private set ownedServantFilter(val: string) {
    this.$store.dispatch('setOwnedServerntFilter', { filter: val })
  }

  private get servants(): Servant[] {
    return this.$store.state.servants
  }
  private get sorter() {
    return getSorter('rarity', true)
  }
  private get classOrder() {
    return servantClassOrder
  }
  private getServantsOfClass(className: string, rarity?: number): Servant[] {
    return this.servants
      .filter(
        s =>
          s.className === className &&
          (rarity === undefined || s.rarity === rarity)
      )
      .sort(this.sorter)
  }
  private getCheckedServantsCount(className: string): number {
    return this.getServantsOfClass(className).filter(s => this.checked(s.id))
      .length
  }
  private getRaritiesOfClass(className: string): number[] {
    const result = [] as number[]
    const rarities = [5, 4, 3, 2, 1, 0]
    rarities.forEach(rarity => {
      if (
        this.servants.some(
          s => s.className === className && s.rarity === rarity
        )
      ) {
        result.push(rarity)
      }
    })
    return result
  }

  private checked(id: number): boolean {
    return this.idList.includes(id)
  }
  private toggle(id: number) {
    const list = this.idList.map(n => n)
    if (this.checked(id)) {
      const index = list.indexOf(id)
      list.splice(index, 1)
    } else {
      list.push(id)
    }
    this.$store.dispatch('setOwnedServants', { idList: list.sort() })
  }
  private toggleAll(className: string, checked: boolean) {
    const list = this.idList.map(n => n)
    this.getServantsOfClass(className).forEach(s => {
      const alreadyChecked = this.checked(s.id)
      if (checked && !alreadyChecked) {
        list.push(s.id)
      } else if (!checked && alreadyChecked) {
        const index = list.indexOf(s.id)
        list.splice(index, 1)
      }
    })
    this.$store.dispatch('setOwnedServants', { idList: list.sort() })
  }
}
</script>

<style lang="scss" scoped></style>
