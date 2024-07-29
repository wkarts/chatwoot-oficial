<script setup>
import { computed } from 'vue';
import Thumbnail from 'dashboard/components/widgets/Thumbnail.vue';
import { useStoreGetters } from 'dashboard/composables/store';
import { useI18n } from 'dashboard/composables/useI18n';

const getters = useStoreGetters();
const props = defineProps({
  macro: {
    type: Object,
    required: true,
  },
});

defineEmits(['edit', 'delete']);
const { t } = useI18n();

const createdByName = computed(() => {
  const createdBy = props.macro.created_by;
  return createdBy.available_name ?? createdBy.email ?? '';
});

const updatedByName = computed(() => {
  const updatedBy = props.macro.updated_by;
  return updatedBy.available_name ?? updatedBy.email ?? '';
});

const visibilityLabel = computed(() => {
  const i18nKey =
    props.macro.visibility === 'global'
      ? 'MACROS.EDITOR.VISIBILITY.GLOBAL.LABEL'
      : 'MACROS.EDITOR.VISIBILITY.PERSONAL.  L';
  return t(i18nKey);
});

const addAccountScoping = url => {
  return `/app/accounts/${getters.getCurrentAccountId.value}/${url}`;
};
</script>

<template>
  <tr>
    <td class="py-4 pr-4 truncate">{{ macro.name }}</td>
    <td class="py-4 pr-4">
      <div v-if="macro.created_by" class="flex items-center">
        <thumbnail :username="createdByName" size="24px" />
        <span class="mx-2">{{ createdByName }}</span>
      </div>
    </td>
    <td class="py-4 pr-4">
      <div v-if="macro.updated_by" class="flex items-center">
        <thumbnail :username="updatedByName" size="24px" />
        <span class="mx-2">{{ updatedByName }}</span>
      </div>
    </td>
    <td class="py-4 pr-4">{{ visibilityLabel }}</td>
    <td class="py-4 flex justify-end gap-1">
      <router-link :to="addAccountScoping(`settings/macros/${macro.id}/edit`)">
        <woot-button
          v-tooltip.top="$t('MACROS.EDIT.TOOLTIP')"
          variant="smooth"
          size="tiny"
          color-scheme="secondary"
          class-names="grey-btn"
          icon="edit"
        />
      </router-link>
      <woot-button
        v-tooltip.top="$t('MACROS.DELETE.TOOLTIP')"
        variant="smooth"
        color-scheme="alert"
        size="tiny"
        icon="dismiss-circle"
        class-names="grey-btn"
        @click="$emit('delete')"
      />
    </td>
  </tr>
</template>
