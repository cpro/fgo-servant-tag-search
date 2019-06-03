import Vue from 'vue'
import Vuex from 'vuex'
Vue.use(Vuex)

import Axios from 'axios'

import Servant, { ServantJsonEntry } from '@/models/servant'
import Tag from '@/models/tag'
import { SortKeyType, getSorter } from '@/models/servantsort'

export default new Vuex.Store({
  state: {
    servants: [] as Servant[],
    tags: [] as Tag[],
    selectFilters: [] as Tag[],
    excludeFilters: [] as Tag[],
    servantSortKey: 'rarity' as SortKeyType,
    servantSortDesc: true,
    ownedServants: [] as number[],
    ownedServantFilter: 'none' as 'none' | 'owned' | 'notowned',
  },
  getters: {
    filteredList: (state, getters): Servant[] => {
      if (state.tags.every(t => t.state === 'none')) {
        return []
      }

      const servants = state.servants.filter(servant => {
        switch (state.ownedServantFilter) {
          case 'none':
            return true
          case 'owned':
            return state.ownedServants.includes(servant.id)
          case 'notowned':
            return !state.ownedServants.includes(servant.id)
        }
      })
      return servants
        .filter(servant => {
          const tagNames = servant.tags.map(t => t.name)
          return (
            getters.selectedTags.every((t: Tag) => tagNames.includes(t.name)) &&
            getters.excludedTags.every((t: Tag) => !tagNames.includes(t.name))
          )
        })
        .sort(getSorter(state.servantSortKey, state.servantSortDesc))
    },
    hasSelectFilter: state => (tagName: string): boolean => {
      return state.selectFilters.some(t => t.name === tagName)
    },
    hasExcludeFilter: state => (tagName: string): boolean => {
      return state.excludeFilters.some(t => t.name === tagName)
    },
    selectedTags: (state): Tag[] => {
      return state.tags.filter(t => t.state === 'select')
    },
    excludedTags: (state): Tag[] => {
      return state.tags.filter(t => t.state === 'exclude')
    },
    queryString: (state, getters) => {
      const selected: Tag[] = getters.selectedTags
      const excluded: Tag[] = getters.excludedTags
      if (selected.length === 0 && excluded.length === 0) {
        return ''
      }
      let query = ''
      if (selected.length > 0) {
        query += '&selected='
        query += selected.map(t => t.name).join(',')
      }
      if (excluded.length > 0) {
        query += '&excluded='
        query += excluded.map(t => t.name).join(',')
      }
      return '?' + query.substring(1)
    },
  },
  mutations: {
    setServants(state, list: Servant[]) {
      state.servants = list
    },
    setTags(state, list: Tag[]) {
      state.tags = list
    },
    setSelectFilters(state, list: Tag[]) {
      state.selectFilters = list
    },
    setExcludeFilters(state, list: Tag[]) {
      state.excludeFilters = list
    },
    setTagState(
      state,
      payload: { tag: Tag; state: 'none' | 'select' | 'exclude' }
    ) {
      const tag = state.tags.find(t => t.name === payload.tag.name)
      if (tag) {
        tag.state = payload.state
      }
    },
    clearTagState(state) {
      state.tags.forEach(t => (t.state = 'none'))
    },
    setServantSort(state, payload: { key: SortKeyType; desc: boolean }) {
      state.servantSortKey = payload.key
      state.servantSortDesc = payload.desc
    },
    setOwnedServants(state, idList: number[]) {
      state.ownedServants = idList
    },
    setOwnedServerntFilter(state, filter: 'none' | 'owned' | 'notowned') {
      state.ownedServantFilter = filter
    },
  },
  actions: {
    async fetchServants({ commit }) {
      const list = (await Axios.get<ServantJsonEntry[]>('../servant.json')).data
      commit('setServants', list.map(data => new Servant(data)))
    },
    async fetchTags({ commit }) {
      const list = (await Axios.get<string[]>('../tag.json')).data
      commit('setTags', list.map(t => new Tag(t)))
    },
    toggleFilter(
      { commit, dispatch },
      payload: { tag: Tag; exclude?: boolean }
    ) {
      commit(
        'setTagState',
        Object.assign(payload, {
          state: payload.tag.getToggledState(payload.exclude),
        })
      )
      dispatch('setHistory')
    },
    addFilter({ commit, dispatch }, payload: { tag: Tag; state: string }) {
      commit('setTagState', Object.assign(payload, { state: payload.state }))
      dispatch('setHistory')
    },
    removeFilter({ commit, dispatch }, payload: { tag: Tag }) {
      commit('setTagState', Object.assign(payload, { state: 'none' }))
      dispatch('setHistory')
    },
    clearFilter({ commit, dispatch }) {
      commit('clearTagState')
      dispatch('setHistory')
    },
    setServantSort({ commit }, payload: { key: SortKeyType; desc: boolean }) {
      commit('setServantSort', payload)
    },
    setOwnedServants({ commit }, payload: { idList: number[] }) {
      commit('setOwnedServants', payload.idList)
      window.localStorage.setItem('ownedservants', payload.idList.join(','))
    },
    loadOwnedServants({ dispatch }) {
      const item = window.localStorage.getItem('ownedservants') || ''
      const idList = item
        .split(',')
        .filter(i => /^[1-9]\d*$/.test(i))
        .map(i => parseInt(i))
      dispatch('setOwnedServants', { idList })
    },
    setOwnedServerntFilter(
      { commit },
      payload: { filter: 'none' | 'owned' | 'notowned' }
    ) {
      commit('setOwnedServerntFilter', payload.filter)
    },
    setHistory({ getters }) {
      const url = '/' + getters.queryString
      window.history.pushState(null, '', url)
    },
    loadSelectionFromUrl({ commit, state }) {
      const params = new URL(window.location.href).searchParams
      const selected = (params.get('selected') || '').split(',')
      const excluded = (params.get('excluded') || '').split(',')

      state.tags.forEach(tag => {
        if (selected.includes(tag.name)) {
          commit('setTagState', { tag, state: 'select' })
        }
        if (excluded.includes(tag.name)) {
          commit('setTagState', { tag, state: 'exclud' })
        }
      })
    },
  },
})
