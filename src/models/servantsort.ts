import Servant from '@/models/servant'

declare type ServantSorter = (
  s1: Servant,
  s2: Servant,
  desc?: boolean
) => number

export declare type SortKeyType = 'id' | 'class' | 'name' | 'rarity'
export const sortKeys: { key: SortKeyType; name: string }[] = [
  {
    key: 'rarity',
    name: 'レアリティ順',
  },
  {
    key: 'class',
    name: 'クラス順',
  },
  {
    key: 'id',
    name: 'ID順',
  },
  {
    key: 'name',
    name: '名前順',
  },
]
export const servantClassOrder = (
  'セイバー,アーチャー,ランサー,ライダー,キャスター,アサシン,バーサーカー,' +
  'ルーラー,アヴェンジャー,アルターエゴ,ムーンキャンサー,フォーリナー,シールダー'
).split(',')

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
const compareWithTable = (
  s1: string,
  s2: string,
  table: string[],
  desc = false
): number => {
  let index1 = table.indexOf(s1)
  if (index1 < 0) {
    index1 = table.length
  }
  let index2 = table.indexOf(s2)
  if (index2 < 0) {
    index2 = table.length
  }
  return compare(index1, index2, desc)
}

const idSorter: ServantSorter = (s1, s2, desc = false) => {
  return compare(s1.id, s2.id, desc)
}

const classSorter: ServantSorter = (s1, s2, desc = false) => {
  return compareWithTable(s1.className, s2.className, servantClassOrder, desc)
}

const raritySorter: ServantSorter = (s1, s2, desc = true) => {
  return compare(s1.rarity, s2.rarity, desc)
}

const nameSorter: ServantSorter = (s1, s2, desc = false) => {
  return compare(s1.name, s2.name, desc)
}

export const getSorter: (key: SortKeyType, desc?: boolean) => ServantSorter = (
  key,
  desc?
) => {
  let sorters: ServantSorter[] = []
  switch (key) {
    case 'id':
      sorters = [idSorter]
      break
    case 'class':
      sorters = [classSorter, raritySorter, idSorter]
      break
    case 'rarity':
      sorters = [raritySorter, classSorter, idSorter]
      break
    case 'name':
      sorters = [nameSorter, raritySorter, classSorter]
      break
  }

  return (s1, s2) => {
    let sort = 0
    sorters.some((sorter, index) => {
      sort = sorter(s1, s2, index === 0 ? desc : undefined)
      return sort !== 0 // 同値でなければ終了
    })
    return sort
  }
}
