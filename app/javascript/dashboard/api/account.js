/* eslint no-console: 0 */
/* global axios */
/* eslint no-undef: "error" */
/* eslint no-unused-expressions: ["error", { "allowShortCircuit": true }] */
import endPoints from './endPoints';

export default {
  getLabels() {
    const urlData = endPoints('fetchLabels');
    const fetchPromise = new Promise((resolve, reject) => {
      axios
        .get(urlData.url)
        .then(response => {
          resolve(response);
        })
        .catch(error => {
          reject(Error(error));
        });
    });
    return fetchPromise;
  },
  // Get Inbox related to the account
  getInboxes() {
    const urlData = endPoints('fetchInboxes');
    const fetchPromise = new Promise((resolve, reject) => {
      axios
        .get(urlData.url)
        .then(response => {
          resolve(response);
        })
        .catch(error => {
          reject(Error(error));
        });
    });
    return fetchPromise;
  },

  deleteInbox(id) {
    const urlData = endPoints('inbox').delete(id);
    const fetchPromise = new Promise((resolve, reject) => {
      axios
        .delete(urlData.url)
        .then(response => {
          resolve(response);
        })
        .catch(error => {
          reject(Error(error));
        });
    });
    return fetchPromise;
  },

  listInboxAgents(id) {
    const urlData = endPoints('inbox').agents.get(id);
    const fetchPromise = new Promise((resolve, reject) => {
      axios
        .get(urlData.url)
        .then(response => {
          resolve(response);
        })
        .catch(error => {
          reject(Error(error));
        });
    });
    return fetchPromise;
  },

  updateInboxAgents(inboxId, agentList) {
    const urlData = endPoints('inbox').agents.post();
    const fetchPromise = new Promise((resolve, reject) => {
      axios
        .post(urlData.url, {
          user_ids: agentList,
          inbox_id: inboxId,
        })
        .then(response => {
          resolve(response);
        })
        .catch(error => {
          reject(Error(error));
        });
    });
    return fetchPromise;
  },
};
