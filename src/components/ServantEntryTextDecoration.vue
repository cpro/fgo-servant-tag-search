<script>
export default {
  functional: true,
  props: {
    text: {
      type: String,
      default: '',
    },
  },
  render(h, { props }) {
    const tnodes = props.text.split(/(\[Lv(?::確率)?\]|＆|[+＋]|<OC:[^>]+>)/)
    return h(
      'span',
      tnodes.map(t => {
        if (/\[Lv(?::確率)?\]/.test(t)) {
          return h('span', { attrs: { class: 'indicator level' } }, ['Lv'])
        } else if (/<OC:[^>]+>/.test(t)) {
          const text = t.replace(/^<|>$/g, '')
          return h('span', { attrs: { class: 'indicator oc' } }, [text])
        } else if (t === '＆') {
          return [h('br'), h('span', { attrs: { class: 'spacer' } }), '& ']
        } else if (t === '＋' || t === '+') {
          return [h('br'), '+ ']
        } else {
          return t
        }
      })
    )
  },
}
</script>

<style lang="scss" scoped>
$level-indicator-color: #0097a7;
$oc-indicator-color: #f57c00;
.indicator {
  display: inline-block;
  box-sizing: border-box;
  height: 16px;
  font-size: 10px;
  border: 1px solid;
  border-radius: 2px;
  padding: 0 3px;
  margin: 0 2px;
  &.level {
    color: $level-indicator-color;
    border-color: $level-indicator-color;
  }
  &.oc {
    color: $oc-indicator-color;
    border-color: $oc-indicator-color;
  }
}
.spacer {
  display: inline-block;
  width: 1.2rem;
}
</style>
