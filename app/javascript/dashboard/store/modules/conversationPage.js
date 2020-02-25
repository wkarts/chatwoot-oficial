import Vue from 'vue';
import * as types from '../mutation-types';

const initialState = {
  currentPage: {
    me: 0,
    unassigned: 0,
    all: 0,
  },
  activeFilter: 'me',
  hasEndReached: {
    me: false,
    unassigned: false,
    all: false,
  },
};

export const getters = {
  getHasEndReached: $state => filter => {
    return $state.hasEndReached[filter];
  },
  getCurrentPage: $state => filter => {
    return $state.currentPage[filter];
  },
  getActiveFilter: $state => $state.activeFilter,
};

export const actions = {
  setActiveFilter({ commit }, filter) {
    commit(types.default.SET_CONVERSATION_PAGE_FILTER, filter);
  },
  setCurrentPage({ commit }, { filter, page }) {
    commit(types.default.SET_CURRENT_PAGE, { filter, page });
  },
  setEndReached({ commit }, { filter }) {
    commit(types.default.SET_CONVERSATION_END_REACHED, { filter });
  },
};

export const mutations = {
  [types.default.SET_CONVERSATION_PAGE_FILTER]: ($state, filter) => {
    $state.activeFilter = filter;
  },
  [types.default.SET_CURRENT_PAGE]: ($state, { filter, page }) => {
    Vue.set($state.currentPage, filter, page);
  },
  [types.default.SET_CONVERSATION_END_REACHED]: ($state, { filter }) => {
    Vue.set($state.hasEndReached, filter, true);
  },
  [types.default.CLEAR_CONVERSATION_PAGE]: $state => {
    $state.currentPage = initialState.currentPage;
    $state.hasEndReached = initialState.hasEndReached;
    $state.activeFilter = initialState.activeFilter;
  },
};

export default {
  namespaced: true,
  state: initialState,
  getters,
  actions,
  mutations,
};
