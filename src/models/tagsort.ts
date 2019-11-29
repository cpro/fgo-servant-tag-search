/* eslint-disable @typescript-eslint/explicit-function-return-type */
import Tag from '@/models/tag'

declare type TagSorter = (tag1: Tag, tag2: Tag) => number

const compare = <T>(a: T, b: T, desc = false): number => {
  const order = desc ? -1 : 1
  if (a < b) {
    return -1 * order
  }
  if (a > b) {
    return 1 * order
  }
  return 0
}

const defaultSorter: TagSorter = (t1, t2) => {
  let diff = compare(t1.pureName, t2.pureName)
  if (diff === 0) {
    diff = compare(t1.target, t2.target)
  }
  return diff
}
const compareWithTable = (s1: string, s2: string, table: string[]): number => {
  let index1 = table.indexOf(s1)
  if (index1 < 0) {
    index1 = table.length
  }
  let index2 = table.indexOf(s2)
  if (index2 < 0) {
    index2 = table.length
  }
  if (index1 === index2) {
    return compare(s1, s2)
  }
  return compare(index1, index2)
}

const classSorter: TagSorter = (t1, t2) => {
  const table = (
    'セイバー,アーチャー,ランサー,ライダー,キャスター,アサシン,バーサーカー,' +
    'ルーラー,アヴェンジャー,アルターエゴ,ムーンキャンサー,フォーリナー,シールダー,' +
    '三騎士,四騎士,エクストラクラス'
  ).split(',')
  return compareWithTable(t1.name, t2.name, table)
}

const raritySorter: TagSorter = (t1, t2) => {
  const suff1 = (t1.name.match(/★\d(以上|以下)?/) || [])[1] || ''
  const suff2 = (t2.name.match(/★\d(以上|以下)?/) || [])[1] || ''
  let diff = compare(suff1, suff2)
  if (diff === 0) {
    diff = compare(t1.name, t2.name)
  }
  return diff
}

const cardSorter: TagSorter = (t1, t2) => {
  const table = 'QAB'
  let diff = compare(
    table.indexOf(t1.name.slice(0, 1)),
    table.indexOf(t2.name.slice(0, 1))
  )
  if (diff === 0) {
    diff = compare(t1.name.slice(1), t2.name.slice(1))
  }
  return diff
}

const attrSorter: TagSorter = (t1, t2) => {
  const table = '秩序,中立,混沌,善,中庸,悪,天属性,地属性,人属性,星属性,獣属性,狂,夏'.split(
    ','
  )
  return compareWithTable(t1.name, t2.name, table)
}

export default (category: string): TagSorter => {
  switch (category) {
    case 'servant_class':
      return classSorter
    case 'servant_rarity':
      return raritySorter
    case 'servant_card':
    case 'servant_noblephantasm':
      return cardSorter
    case 'servant_attr':
      return attrSorter
    default:
      return defaultSorter
  }
}
