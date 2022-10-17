import { getters } from './getters';
import { actions } from './actions';
import { mutations } from './mutations';

export const defaultPortalFlags = {
  isFetching: false,
  isUpdating: false,
  isDeleting: false,
};

const state = {
  meta: {
    count: 0,
    currentPage: 1,
  },

  portals: {
    byId: {},
    allIds: [],
    uiFlags: {
      byId: {
        // 1: { isFetching: false, isUpdating: false, isDeleting: false },
      },
    },
    meta: {
      byId: {},
    },
  },
  uiFlags: {
    allFetched: false,
    isFetching: false,
  },
  selectedPortalMetadata: {},
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
