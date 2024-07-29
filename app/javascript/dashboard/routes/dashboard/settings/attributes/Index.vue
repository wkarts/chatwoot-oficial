<template>
  <div class="flex-1 overflow-auto">
    <BaseSettingsHeader
      :title="$t('ATTRIBUTES_MGMT.HEADER')"
      :description="$t('ATTRIBUTES_MGMT.DESCRIPTION')"
      :link-text="$t('ATTRIBUTES_MGMT.LEARN_MORE')"
      feature-name="custom_attributes"
    >
      <template #actions>
        <woot-button
          class="button nice rounded-md"
          icon="add-circle"
          @click="openAddPopup"
        >
          {{ $t('ATTRIBUTES_MGMT.HEADER_BTN_TXT') }}
        </woot-button>
      </template>
    </BaseSettingsHeader>
    <custom-attribute />
    <woot-modal :show.sync="showAddPopup" :on-close="hideAddPopup">
      <add-attribute :on-close="hideAddPopup" />
    </woot-modal>
  </div>
</template>

<script>
import BaseSettingsHeader from '../components/BaseSettingsHeader.vue';
import AddAttribute from './AddAttribute.vue';
import CustomAttribute from './CustomAttribute.vue';
export default {
  components: {
    AddAttribute,
    BaseSettingsHeader,
    CustomAttribute,
  },
  data() {
    return {
      showAddPopup: false,
    };
  },
  methods: {
    openAddPopup() {
      this.showAddPopup = true;
    },
    hideAddPopup() {
      this.showAddPopup = false;
    },
  },
};
</script>

<style></style>
