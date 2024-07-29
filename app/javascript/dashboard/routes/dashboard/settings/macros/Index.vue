<template>
  <div class="flex-1 overflow-auto">
    <BaseSettingsHeader
      :title="$t('MACROS.HEADER')"
      :description="$t('MACROS.DESCRIPTION')"
      :link-text="$t('MACROS.LEARN_MORE')"
      feature-name="macros"
    >
      <template #actions>
        <router-link
          :to="addAccountScoping('settings/macros/new')"
          class="button rounded-md primary"
        >
          <fluent-icon icon="add-circle" />
          <span class="button__content">
            {{ $t('MACROS.HEADER_BTN_TXT') }}
          </span>
        </router-link>
      </template>
    </BaseSettingsHeader>

    <div class="w-full flex flex-row gap-4 mt-6">
      <div v-if="!uiFlags.isFetching && !records.length" class="p-3">
        <p class="flex h-full items-center flex-col justify-center">
          {{ $t('MACROS.LIST.404') }}
        </p>
      </div>
      <woot-loading-state
        v-if="uiFlags.isFetching"
        :message="$t('MACROS.LOADING')"
      />
      <table
        v-if="!uiFlags.isFetching && records.length"
        class="min-w-full divide-y divide-slate-75 dark:divide-slate-700"
      >
        <thead>
          <th
            v-for="thHeader in $t('MACROS.LIST.TABLE_HEADER')"
            :key="thHeader"
            class="py-4 pr-4 text-left font-semibold text-slate-700 dark:text-slate-300"
          >
            {{ thHeader }}
          </th>
        </thead>
        <tbody
          class="divide-y divide-slate-50 dark:divide-slate-800 text-slate-700 dark:text-slate-300"
        >
          <macros-table-row
            v-for="(macro, index) in records"
            :key="index"
            :macro="macro"
            @delete="openDeletePopup(macro, index)"
          />
        </tbody>
      </table>
    </div>

    <woot-delete-modal
      :show.sync="showDeleteConfirmationPopup"
      :on-close="closeDeletePopup"
      :on-confirm="confirmDeletion"
      :title="$t('LABEL_MGMT.DELETE.CONFIRM.TITLE')"
      :message="$t('MACROS.DELETE.CONFIRM.MESSAGE')"
      :message-value="deleteMessage"
      :confirm-text="$t('MACROS.DELETE.CONFIRM.YES')"
      :reject-text="$t('MACROS.DELETE.CONFIRM.NO')"
    />
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import { useAlert } from 'dashboard/composables';
import accountMixin from 'dashboard/mixins/account.js';
import MacrosTableRow from './MacrosTableRow.vue';
import BaseSettingsHeader from '../components/BaseSettingsHeader.vue';
export default {
  components: {
    BaseSettingsHeader,
    MacrosTableRow,
  },
  mixins: [accountMixin],
  data() {
    return {
      showDeleteConfirmationPopup: false,
      selectedResponse: {},
      loading: {},
    };
  },
  computed: {
    ...mapGetters({
      records: ['macros/getMacros'],
      uiFlags: 'macros/getUIFlags',
    }),
    deleteMessage() {
      return ` ${this.selectedResponse.name}?`;
    },
  },
  mounted() {
    this.$store.dispatch('macros/get');
  },
  methods: {
    openDeletePopup(response) {
      this.showDeleteConfirmationPopup = true;
      this.selectedResponse = response;
    },
    closeDeletePopup() {
      this.showDeleteConfirmationPopup = false;
    },
    confirmDeletion() {
      this.loading[this.selectedResponse.id] = true;
      this.closeDeletePopup();
      this.deleteMacro(this.selectedResponse.id);
    },
    async deleteMacro(id) {
      try {
        await this.$store.dispatch('macros/delete', id);
        useAlert(this.$t('MACROS.DELETE.API.SUCCESS_MESSAGE'));
        this.loading[this.selectedResponse.id] = false;
      } catch (error) {
        useAlert(this.$t('MACROS.DELETE.API.ERROR_MESSAGE'));
      }
    },
  },
};
</script>
