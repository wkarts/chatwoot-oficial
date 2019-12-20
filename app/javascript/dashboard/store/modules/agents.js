import * as types from '../mutation-types';
import AgentAPI from '../../api/agents';

export const state = {
  records: [],
  uiFlags: {
    isFetching: false,
    isCreating: false,
    isUpdating: false,
    isDeleting: false,
  },
};

export const getters = {
  getAgents($state) {
    return $state.records;
  },
  getVerifiedAgents($state) {
    return $state.records.filter(record => record.confirmed);
  },
  getUIFlags($state) {
    return $state.uiFlags;
  },
};

export const actions = {
  get: async ({ commit }) => {
    commit(types.default.SET_AGENT_FETCHING_STATUS, true);
    try {
      const response = await AgentAPI.get();
      commit(types.default.SET_AGENT_FETCHING_STATUS, false);
      commit(types.default.SET_AGENTS, response.data);
    } catch (error) {
      commit(types.default.SET_AGENT_FETCHING_STATUS, false);
    }
  },
  create: async ({ commit }, agentInfo) => {
    commit(types.default.SET_AGENT_CREATING_STATUS, true);
    try {
      const response = await AgentAPI.create(agentInfo);
      commit(types.default.ADD_AGENT, response.data);
      commit(types.default.SET_AGENT_CREATING_STATUS, false);
    } catch (error) {
      commit(types.default.SET_AGENT_CREATING_STATUS, false);
      throw new Error(error);
    }
  },
  update: async ({ commit }, { id, ...agentParams }) => {
    commit(types.default.SET_AGENT_UPDATING_STATUS, true);
    try {
      const response = await AgentAPI.update(id, agentParams);
      commit(types.default.EDIT_AGENT, response.data);
      commit(types.default.SET_AGENT_UPDATING_STATUS, false);
    } catch (error) {
      commit(types.default.SET_AGENT_UPDATING_STATUS, false);
      throw new Error(error);
    }
  },
  delete: async ({ commit }, agentId) => {
    commit(types.default.SET_AGENT_DELETING_STATUS, true);
    try {
      await AgentAPI.delete(agentId);
      commit(types.default.DELETE_AGENT, agentId);
      commit(types.default.SET_AGENT_DELETING_STATUS, false);
    } catch (error) {
      commit(types.default.SET_AGENT_DELETING_STATUS, false);
      throw new Error(error);
    }
  },
};

export const mutations = {
  [types.default.SET_AGENT_FETCHING_STATUS]($state, status) {
    $state.uiFlags.isFetching = status;
  },
  [types.default.SET_AGENT_CREATING_STATUS]($state, status) {
    $state.uiFlags.isCreating = status;
  },
  [types.default.SET_AGENT_UPDATING_STATUS]($state, status) {
    $state.uiFlags.isUpdating = status;
  },
  [types.default.SET_AGENT_DELETING_STATUS]($state, status) {
    $state.uiFlags.isDeleting = status;
  },

  [types.default.SET_AGENTS]($state, agentList) {
    $state.records = agentList;
  },
  [types.default.ADD_AGENT]($state, agentData) {
    $state.records.push(agentData);
  },
  [types.default.EDIT_AGENT]($state, agentData) {
    $state.records.forEach((element, index) => {
      if (element.id === agentData.id) {
        $state.records[index] = agentData;
      }
    });
  },
  [types.default.DELETE_AGENT]($state, agentId) {
    $state.records = $state.records.filter(agent => agent.id !== agentId);
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
