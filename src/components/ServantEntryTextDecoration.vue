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
    const tnodes = props.text.split(/(\[Lv\])/)
    return h(
      'span',
      tnodes.map(t => {
        if (t === '[Lv]') {
          return h(
            'span',
            {
              attrs: { class: 'level' },
            },
            ['Lv']
          )
        } else {
          return t
        }
      })
    )
  },
}
</script>

<style lang="scss" scoped>
$main-color: #9e9e9e;
.level {
  display: inline-block;
  color: $main-color;
  border: 1px solid $main-color;
  font-size: 70%;
  border-radius: 2px;
  padding: 0 3px;
  margin: 0 1px;
  line-height: 0.9rem;
  vertical-align: middle;
}
</style>
