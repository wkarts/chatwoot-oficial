<template>
  <div class="flex-1 overflow-auto">
    <BaseSettingsHeader
      :title="$t('AUDIT_LOGS.HEADER')"
      :description="$t('AUDIT_LOGS.DESCRIPTION')"
      :link-text="$t('AUDIT_LOGS.LEARN_MORE')"
      feature-name="audit_logs"
    />

    <div class="mt-6 w-full gap-4">
      <p
        v-if="!uiFlags.fetchingList && !records.length"
        class="flex flex-col items-center justify-center h-full"
      >
        {{ $t('AUDIT_LOGS.LIST.404') }}
      </p>
      <woot-loading-state
        v-if="uiFlags.fetchingList"
        :message="$t('AUDIT_LOGS.LOADING')"
      />

      <table
        v-if="!uiFlags.fetchingList && records.length"
        class="min-w-full divide-y divide-slate-75 dark:divide-slate-700"
      >
        <thead>
          <th
            v-for="thHeader in $t('AUDIT_LOGS.LIST.TABLE_HEADER')"
            :key="thHeader"
            class="py-4 pr-4 text-left font-semibold text-slate-700 dark:text-slate-300"
          >
            {{ thHeader }}
          </th>
        </thead>
        <tbody
          class="divide-y divide-slate-50 dark:divide-slate-800 text-slate-700 dark:text-slate-300"
        >
          <tr v-for="auditLogItem in records" :key="auditLogItem.id">
            <td class="py-4 pr-4 break-all whitespace-nowrap">
              {{ generateLogText(auditLogItem) }}
            </td>
            <td class="py-4 pr-4 break-all whitespace-nowrap">
              {{
                messageTimestamp(
                  auditLogItem.created_at,
                  'MMM dd, yyyy hh:mm a'
                )
              }}
            </td>
            <td class="py-4 w-[8.75rem]">
              {{ auditLogItem.remote_address }}
            </td>
          </tr>
        </tbody>
      </table>
      <table-footer
        :current-page="Number(meta.currentPage)"
        :total-count="meta.totalEntries"
        :page-size="meta.perPage"
        class="border-slate-50 dark:border-slate-800 border-t !px-0"
        @page-change="onPageChange"
      />
    </div>
  </div>
</template>
<script>
import { mapGetters } from 'vuex';
import { useAlert } from 'dashboard/composables';
import { messageTimestamp } from 'shared/helpers/timeHelper';
import TableFooter from 'dashboard/components/widgets/TableFooter.vue';
import {
  generateTranslationPayload,
  generateLogActionKey,
} from 'dashboard/helper/auditlogHelper';
import BaseSettingsHeader from '../components/BaseSettingsHeader.vue';

export default {
  components: {
    TableFooter,
    BaseSettingsHeader,
  },
  beforeRouteEnter(to, from, next) {
    // Fetch Audit Logs on page load without manual refresh
    next(vm => {
      vm.fetchAuditLogs();
    });
  },
  data() {
    return {
      loading: {},
      auditLogsAPI: {
        message: '',
      },
    };
  },
  computed: {
    ...mapGetters({
      records: 'auditlogs/getAuditLogs',
      uiFlags: 'auditlogs/getUIFlags',
      meta: 'auditlogs/getMeta',
      agentList: 'agents/getAgents',
    }),
  },
  mounted() {
    // Fetch API Call
    this.$store.dispatch('agents/get');
  },
  methods: {
    messageTimestamp,
    fetchAuditLogs() {
      const page = this.$route.query.page ?? 1;
      this.$store.dispatch('auditlogs/fetch', { page }).catch(error => {
        const errorMessage =
          error?.message || this.$t('AUDIT_LOGS.API.ERROR_MESSAGE');
        useAlert(errorMessage);
      });
    },
    generateLogText(auditLogItem) {
      const translationPayload = generateTranslationPayload(
        auditLogItem,
        this.agentList
      );
      const translationKey = generateLogActionKey(auditLogItem);

      return this.$t(translationKey, translationPayload);
    },
    onPageChange(page) {
      window.history.pushState({}, null, `${this.$route.path}?page=${page}`);
      try {
        this.$store.dispatch('auditlogs/fetch', { page });
      } catch (error) {
        const errorMessage =
          error?.message || this.$t('AUDIT_LOGS.API.ERROR_MESSAGE');
        useAlert(errorMessage);
      }
    },
  },
};
</script>
