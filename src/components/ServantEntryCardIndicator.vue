<template>
  <span :class="colorClass">{{ text }}</span>
</template>

<script lang="ts">
import { Component, Prop, Vue } from 'vue-property-decorator'

@Component
export default class ServantEntryCardIndicator extends Vue {
  @Prop(String)
  private text!: string

  private get colorClass(): string {
    return this.text.slice(0, 1).toLowerCase()
  }
}
</script>

<style lang="scss" scoped>
span {
  display: inline-block;
  padding: 0 2px;
  margin: 0 1px 0 0;
  border-radius: 2px;
  border-width: 1px;
  border-style: solid;

  &.q {
    border-color: #4caf50;
    color: #4caf50;
  }
  &.a {
    border-color: #2196f3;
    color: #2196f3;
  }
  &.b {
    border-color: #d81b60;
    color: #d81b60;
  }
}
</style>
