<template>
  <div class="flex-1 overflow-auto w-full">
    <BaseSettingsHeader
      :title="integration.name"
      :description="integration.description"
      :link-text="$t('INTEGRATION_SETTINGS.WEBHOOK.LEARN_MORE')"
      feature-name="webhook"
      :back-button-label="$t('INTEGRATION_SETTINGS.HEADER')"
    >
      <template #actions>
        <woot-button
          class="button nice rounded-md"
          icon="add-circle"
          @click="openAddPopup"
        >
          {{ $t('INTEGRATION_SETTINGS.WEBHOOK.HEADER_BTN_TXT') }}
        </woot-button>
      </template>
    </BaseSettingsHeader>

    <div class="mt-6 w-full text-slate-700 dark:text-slate-200">
      <p
        v-if="!uiFlags.fetchingList && !records.length"
        class="flex flex-col items-center justify-center h-full p-4 w-full"
      >
        {{ $t('INTEGRATION_SETTINGS.WEBHOOK.LIST.404') }}
      </p>
      <woot-loading-state
        v-if="uiFlags.fetchingList"
        :message="$t('INTEGRATION_SETTINGS.WEBHOOK.LOADING')"
      />

      <table
        v-if="!uiFlags.fetchingList && records.length"
        class="min-w-full divide-y divide-slate-75 dark:divide-slate-700"
      >
        <thead>
          <th
            v-for="thHeader in $t(
              'INTEGRATION_SETTINGS.WEBHOOK.LIST.TABLE_HEADER'
            )"
            :key="thHeader"
            class="py-4 pr-4 text-left font-semibold text-slate-700 dark:text-slate-300 last:text-right last:pr-4"
          >
            {{ thHeader }}
          </th>
        </thead>
        <tbody>
          <webhook-row
            v-for="(webHookItem, index) in records"
            :key="webHookItem.id"
            :index="index"
            :webhook="webHookItem"
            @edit="openEditPopup"
            @delete="openDeletePopup"
          />
        </tbody>
      </table>
    </div>

    <woot-modal :show.sync="showAddPopup" :on-close="hideAddPopup">
      <new-webhook v-if="showAddPopup" :on-close="hideAddPopup" />
    </woot-modal>

    <woot-modal :show.sync="showEditPopup" :on-close="hideEditPopup">
      <edit-webhook
        v-if="showEditPopup"
        :id="selectedWebHook.id"
        :value="selectedWebHook"
        :on-close="hideEditPopup"
      />
    </woot-modal>
    <woot-delete-modal
      :show.sync="showDeleteConfirmationPopup"
      :on-close="closeDeletePopup"
      :on-confirm="confirmDeletion"
      :title="$t('INTEGRATION_SETTINGS.WEBHOOK.DELETE.CONFIRM.TITLE')"
      :message="
        $t('INTEGRATION_SETTINGS.WEBHOOK.DELETE.CONFIRM.MESSAGE', {
          webhookURL: selectedWebHook.url,
        })
      "
      :confirm-text="$t('INTEGRATION_SETTINGS.WEBHOOK.DELETE.CONFIRM.YES')"
      :reject-text="$t('INTEGRATION_SETTINGS.WEBHOOK.DELETE.CONFIRM.NO')"
    />
  </div>
</template>
<script>
import { mapGetters } from 'vuex';
import { useAlert } from 'dashboard/composables';
import NewWebhook from './NewWebHook.vue';
import EditWebhook from './EditWebHook.vue';
import WebhookRow from './WebhookRow.vue';
import BaseSettingsHeader from '../../components/BaseSettingsHeader.vue';

export default {
  components: {
    BaseSettingsHeader,
    NewWebhook,
    EditWebhook,
    WebhookRow,
  },
  data() {
    return {
      loading: {},
      showAddPopup: false,
      showEditPopup: false,
      showDeleteConfirmationPopup: false,
      selectedWebHook: {},
    };
  },
  computed: {
    ...mapGetters({
      records: 'webhooks/getWebhooks',
      uiFlags: 'webhooks/getUIFlags',
      globalConfig: 'globalConfig/get',
    }),
    integration() {
      return this.$store.getters['integrations/getIntegration']('webhook');
    },
  },
  mounted() {
    this.$store.dispatch('webhooks/get');
  },
  methods: {
    openAddPopup() {
      this.showAddPopup = true;
    },
    hideAddPopup() {
      this.showAddPopup = false;
    },
    openDeletePopup(response) {
      this.showDeleteConfirmationPopup = true;
      this.selectedWebHook = response;
    },
    closeDeletePopup() {
      this.showDeleteConfirmationPopup = false;
    },
    openEditPopup(webhook) {
      this.showEditPopup = true;
      this.selectedWebHook = webhook;
    },
    hideEditPopup() {
      this.showEditPopup = false;
    },
    confirmDeletion() {
      this.loading[this.selectedWebHook.id] = true;
      this.closeDeletePopup();
      this.deleteWebhook(this.selectedWebHook.id);
    },
    async deleteWebhook(id) {
      try {
        await this.$store.dispatch('webhooks/delete', id);
        useAlert(
          this.$t('INTEGRATION_SETTINGS.WEBHOOK.DELETE.API.SUCCESS_MESSAGE')
        );
      } catch (error) {
        useAlert(
          this.$t('INTEGRATION_SETTINGS.WEBHOOK.DELETE.API.ERROR_MESSAGE')
        );
      }
    },
  },
};
</script>
