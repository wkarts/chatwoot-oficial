<template>
  <div class="flex-1 overflow-auto">
    <BaseSettingsHeader
      :title="$t('TEAMS_SETTINGS.HEADER')"
      :description="$t('TEAMS_SETTINGS.DESCRIPTION')"
      :link-text="$t('TEAMS_SETTINGS.LEARN_MORE')"
      feature-name="team_management"
    >
      <template #actions>
        <router-link
          :to="addAccountScoping('settings/teams/new')"
          class="button rounded-md primary"
        >
          <fluent-icon icon="add-circle" />
          <span class="button__content">
            {{ $t('TEAMS_SETTINGS.NEW_TEAM') }}
          </span>
        </router-link>
      </template>
    </BaseSettingsHeader>
    <div class="mt-6 w-full flex gap-4">
      <p
        v-if="!teamsList.length"
        class="flex flex-col items-center justify-center h-full"
      >
        {{ $t('TEAMS_SETTINGS.LIST.404') }}
        <router-link
          v-if="isAdmin"
          :to="addAccountScoping('settings/teams/new')"
        >
          {{ $t('TEAMS_SETTINGS.NEW_TEAM') }}
        </router-link>
      </p>

      <table
        v-if="teamsList.length"
        class="min-w-full divide-y divide-slate-75 dark:divide-slate-700"
      >
        <tbody
          class="divide-y divide-slate-50 dark:divide-slate-800 text-slate-700 dark:text-slate-300"
        >
          <tr v-for="item in teamsList" :key="item.id">
            <td class="py-4 pr-4">
              <span class="block font-medium capitalize">{{ item.name }}</span>
              <p class="mb-0">{{ item.description }}</p>
            </td>

            <td class="py-4 flex justify-end gap-1">
              <router-link
                :to="addAccountScoping(`settings/teams/${item.id}/edit`)"
              >
                <woot-button
                  v-if="isAdmin"
                  v-tooltip.top="$t('TEAMS_SETTINGS.LIST.EDIT_TEAM')"
                  variant="smooth"
                  size="tiny"
                  color-scheme="secondary"
                  class-names="grey-btn"
                  icon="settings"
                />
              </router-link>
              <woot-button
                v-if="isAdmin"
                v-tooltip.top="$t('TEAMS_SETTINGS.DELETE.BUTTON_TEXT')"
                variant="smooth"
                color-scheme="alert"
                size="tiny"
                icon="dismiss-circle"
                class-names="grey-btn"
                :is-loading="loading[item.id]"
                @click="openDelete(item)"
              />
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <woot-confirm-delete-modal
      v-if="showDeletePopup"
      :show.sync="showDeletePopup"
      :title="confirmDeleteTitle"
      :message="$t('TEAMS_SETTINGS.DELETE.CONFIRM.MESSAGE')"
      :confirm-text="deleteConfirmText"
      :reject-text="deleteRejectText"
      :confirm-value="selectedTeam.name"
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
import accountMixin from '../../../../mixins/account';
import BaseSettingsHeader from '../components/BaseSettingsHeader.vue';

export default {
  components: {
    BaseSettingsHeader,
  },
  mixins: [accountMixin],
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
      selectedTeam: {},
    };
  },
  computed: {
    ...mapGetters({
      teamsList: 'teams/getTeams',
      globalConfig: 'globalConfig/get',
    }),
    deleteConfirmText() {
      return `${this.$t('TEAMS_SETTINGS.DELETE.CONFIRM.YES')} ${
        this.selectedTeam.name
      }`;
    },
    deleteRejectText() {
      return this.$t('TEAMS_SETTINGS.DELETE.CONFIRM.NO');
    },
    confirmDeleteTitle() {
      return this.$t('TEAMS_SETTINGS.DELETE.CONFIRM.TITLE', {
        teamName: this.selectedTeam.name,
      });
    },
    confirmPlaceHolderText() {
      return `${this.$t('TEAMS_SETTINGS.DELETE.CONFIRM.PLACE_HOLDER', {
        teamName: this.selectedTeam.name,
      })}`;
    },
  },
  methods: {
    async deleteTeam({ id }) {
      try {
        await this.$store.dispatch('teams/delete', id);
        useAlert(this.$t('TEAMS_SETTINGS.DELETE.API.SUCCESS_MESSAGE'));
      } catch (error) {
        useAlert(this.$t('TEAMS_SETTINGS.DELETE.API.ERROR_MESSAGE'));
      }
    },

    confirmDeletion() {
      this.deleteTeam(this.selectedTeam);
      this.closeDelete();
    },
    openDelete(team) {
      this.showDeletePopup = true;
      this.selectedTeam = team;
    },
    closeDelete() {
      this.showDeletePopup = false;
      this.selectedTeam = {};
    },
  },
};
</script>
<style lang="scss" scoped>
.button-wrapper {
  min-width: unset;
  justify-content: flex-end;
  padding-right: var(--space-large);
}
</style>
