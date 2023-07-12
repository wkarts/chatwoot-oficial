import { mapGetters } from 'vuex';
import { OPEN_AI_EVENTS } from '../helper/AnalyticsHelper/events';

export default {
  computed: {
    ...mapGetters({
      appIntegrations: 'integrations/getAppIntegrations',
      currentChat: 'getSelectedChat',
    }),
    isAIIntegrationEnabled() {
      return this.appIntegrations.find(
        integration => integration.id === 'openai' && !!integration.hooks.length
      );
    },
    hookId() {
      return this.appIntegrations.find(
        integration => integration.id === 'openai' && !!integration.hooks.length
      ).hooks[0].id;
    },
    draftMessage() {
      return this.$store.getters['draftMessages/get'](this.draftKey);
    },
    draftKey() {
      // TODO: Remove this hardcoding REPLY
      return `draft-${this.conversationId}-REPLY`;
    },
    conversationId() {
      return this.currentChat?.id;
    },
  },
  methods: {
    async recordAnalytics(type, payload) {
      const event = OPEN_AI_EVENTS[type.toUpperCase()];
      if (event) {
        this.$track(event, {
          type,
          ...payload,
        });
      }
    },
  },
};
