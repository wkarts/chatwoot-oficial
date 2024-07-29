<template>
  <div class="flex-1 overflow-auto">
    <BaseSettingsHeader
      :title="$t('INBOX_MGMT.HEADER')"
      :description="$t('INBOX_MGMT.DESCRIPTION')"
      :link-text="$t('INBOX_MGMT.LEARN_MORE')"
      feature-name="agents"
    >
      <template #actions>
        <router-link
          v-if="isAdmin"
          class="button nice rounded-md"
          :to="addAccountScoping('settings/inboxes/new')"
        >
          <fluent-icon icon="add-circle" type="outline" size="14" />
          {{ $t('SETTINGS.INBOXES.NEW_INBOX') }}
        </router-link>
      </template>
    </BaseSettingsHeader>
    <div class="w-full flex flex-row gap-4 mt-6">
      <p
        v-if="!inboxesList.length"
        class="flex flex-col items-center justify-center h-full"
      >
        {{ $t('INBOX_MGMT.LIST.404') }}
        <router-link
          v-if="isAdmin"
          :to="addAccountScoping('settings/inboxes/new')"
        >
          {{ $t('SETTINGS.INBOXES.NEW_INBOX') }}
        </router-link>
      </p>

      <table
        v-if="inboxesList.length"
        class="min-w-full divide-y divide-slate-75 dark:divide-slate-700"
      >
        <tbody
          class="divide-y divide-slate-50 dark:divide-slate-800 text-slate-700 dark:text-slate-300"
        >
          <tr v-for="item in inboxesList" :key="item.id">
            <td class="py-4 pr-4">
              <div class="flex flex-row gap-4">
                <img
                  v-if="item.avatar_url"
                  class="h-10 w-10 rounded-full"
                  :src="item.avatar_url"
                  alt="No Page Image"
                />
                <img
                  v-else
                  class="h-10 w-10 rounded-full"
                  src="~dashboard/assets/images/flag.svg"
                  alt="No Page Image"
                />
                <div>
                  <span class="block font-medium capitalize">
                    {{ item.name }}
                  </span>
                  <span v-if="item.channel_type === 'Channel::FacebookPage'">
                    Facebook
                  </span>
                  <span v-if="item.channel_type === 'Channel::WebWidget'">
                    Website
                  </span>
                  <span v-if="item.channel_type === 'Channel::TwitterProfile'">
                    Twitter
                  </span>
                  <span v-if="item.channel_type === 'Channel::TwilioSms'">
                    {{ twilioChannelName(item) }}
                  </span>
                  <span v-if="item.channel_type === 'Channel::Whatsapp'">
                    Whatsapp
                  </span>
                  <span v-if="item.channel_type === 'Channel::Sms'"> Sms </span>
                  <span v-if="item.channel_type === 'Channel::Email'">
                    Email
                  </span>
                  <span v-if="item.channel_type === 'Channel::Telegram'">
                    Telegram
                  </span>
                  <span v-if="item.channel_type === 'Channel::Line'">Line</span>
                  <span v-if="item.channel_type === 'Channel::Api'">
                    {{ globalConfig.apiChannelName || 'API' }}
                  </span>
                </div>
              </div>
            </td>

            <td class="py-4 pr-4 flex justify-end gap-1">
              <router-link
                :to="addAccountScoping(`settings/inboxes/${item.id}`)"
              >
                <woot-button
                  v-if="isAdmin"
                  v-tooltip.top="$t('INBOX_MGMT.SETTINGS')"
                  variant="smooth"
                  size="tiny"
                  icon="settings"
                  color-scheme="secondary"
                  class-names="grey-btn"
                />
              </router-link>

              <woot-button
                v-if="isAdmin"
                v-tooltip.top="$t('INBOX_MGMT.DELETE.BUTTON_TEXT')"
                variant="smooth"
                color-scheme="alert"
                size="tiny"
                class-names="grey-btn"
                :is-loading="loading[item.id]"
                icon="dismiss-circle"
                @click="openDelete(item)"
              />
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <settings
      v-if="showSettings"
      :show.sync="showSettings"
      :on-close="closeSettings"
      :inbox="selectedInbox"
    />

    <woot-confirm-delete-modal
      v-if="showDeletePopup"
      :show.sync="showDeletePopup"
      :title="$t('INBOX_MGMT.DELETE.CONFIRM.TITLE')"
      :message="confirmDeleteMessage"
      :confirm-text="deleteConfirmText"
      :reject-text="deleteRejectText"
      :confirm-value="selectedInbox.name"
      :confirm-place-holder-text="confirmPlaceHolderText"
      @on-confirm="confirmDeletion"
      @on-close="closeDelete"
    />
  </div>
</template>
<script>
import { mapGetters } from 'vuex';
import { useAlert } from 'dashboard/composables';
import { useAdmin } from 'dashboard/composables/useAdmin';
import Settings from './Settings.vue';
import accountMixin from '../../../../mixins/account';
import globalConfigMixin from 'shared/mixins/globalConfigMixin';
import BaseSettingsHeader from '../components/BaseSettingsHeader.vue';

export default {
  components: {
    BaseSettingsHeader,
    Settings,
  },
  mixins: [accountMixin, globalConfigMixin],
  setup() {
    const { isAdmin } = useAdmin();
    return {
      isAdmin,
    };
  },
  data() {
    return {
      loading: {},
      showSettings: false,
      showDeletePopup: false,
      selectedInbox: {},
    };
  },
  computed: {
    ...mapGetters({
      inboxesList: 'inboxes/getInboxes',
      globalConfig: 'globalConfig/get',
    }),
    // Delete Modal
    deleteConfirmText() {
      return `${this.$t('INBOX_MGMT.DELETE.CONFIRM.YES')} ${
        this.selectedInbox.name
      }`;
    },
    deleteRejectText() {
      return `${this.$t('INBOX_MGMT.DELETE.CONFIRM.NO')} ${
        this.selectedInbox.name
      }`;
    },
    confirmDeleteMessage() {
      return `${this.$t('INBOX_MGMT.DELETE.CONFIRM.MESSAGE')} ${
        this.selectedInbox.name
      }?`;
    },
    confirmPlaceHolderText() {
      return `${this.$t('INBOX_MGMT.DELETE.CONFIRM.PLACE_HOLDER', {
        inboxName: this.selectedInbox.name,
      })}`;
    },
  },
  methods: {
    twilioChannelName(item) {
      const { medium = '' } = item;
      if (medium === 'whatsapp') return 'WhatsApp';
      return 'Twilio SMS';
    },
    openSettings(inbox) {
      this.showSettings = true;
      this.selectedInbox = inbox;
    },
    closeSettings() {
      this.showSettings = false;
      this.selectedInbox = {};
    },
    async deleteInbox({ id }) {
      try {
        await this.$store.dispatch('inboxes/delete', id);
        useAlert(this.$t('INBOX_MGMT.DELETE.API.SUCCESS_MESSAGE'));
      } catch (error) {
        useAlert(this.$t('INBOX_MGMT.DELETE.API.ERROR_MESSAGE'));
      }
    },

    confirmDeletion() {
      this.deleteInbox(this.selectedInbox);
      this.closeDelete();
    },
    openDelete(inbox) {
      this.showDeletePopup = true;
      this.selectedInbox = inbox;
    },
    closeDelete() {
      this.showDeletePopup = false;
      this.selectedInbox = {};
    },
  },
};
</script>
