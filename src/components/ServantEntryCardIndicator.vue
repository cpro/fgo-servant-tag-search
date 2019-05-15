<template functional>
  <span :class="props.text.slice(0, 1).toLowerCase()">{{ props.text }}</span>
</template>

<script>
export default {
  name: 'ServantEntryCardIndicator',
  props: {
    text: {
      type: String,
      default: '',
    },
  },
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
