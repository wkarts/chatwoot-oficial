<template>
  <div class="wizard-body columns content-box small-9">
    <div v-if="!hasLoginStarted" class="login-init full-height">
      <a href="#" @click="startLogin()">
        <img
          src="~dashboard/assets/images/channels/facebook_login.png"
          alt="Facebook-logo"
        />
      </a>
      <p>
        {{
          useInstallationName(
            $t('INBOX_MGMT.ADD.FB.HELP'),
            globalConfig.installationName
          )
        }}
      </p>
    </div>
    <div v-else>
      <loading-state v-if="showLoader" :message="emptyStateMessage" />
    </div>
  </div>
</template>
<script>
/* eslint-env browser */
/* global FB */
import { required } from 'vuelidate/lib/validators';
import LoadingState from 'dashboard/components/widgets/LoadingState';
import { mapGetters } from 'vuex';
import ChannelApi from '../../../../../api/channels';
import PageHeader from '../../SettingsSubPageHeader';
import router from '../../../../index';
import globalConfigMixin from 'shared/mixins/globalConfigMixin';
import accountMixin from '../../../../../mixins/account';

export default {
  components: {
    LoadingState,
    PageHeader,
  },
  mixins: [globalConfigMixin, accountMixin],
  data() {
    return {
      isCreating: false,
      omniauth_token: '',
      user_access_token: '',
      channel: 'facebook',
      selectedPage: { name: null, id: null },
      pageName: '',
      pageList: [],
      emptyStateMessage: this.$t('INBOX_MGMT.DETAILS.LOADING_FB'),
      hasLoginStarted: false,
    };
  },

  validations: {
    pageName: {
      required,
    },

    selectedPage: {
      isEmpty() {
        return this.selectedPage !== null && !!this.selectedPage.name;
      },
    },
  },

  computed: {
    showLoader() {
      return !this.user_access_token || this.isCreating;
    },
    getSelectablePages() {
      return this.pageList.filter(item => !item.exists);
    },
    ...mapGetters({
      currentUser: 'getCurrentUser',
      globalConfig: 'globalConfig/get',
    }),
  },

  created() {
    this.initFB();
    this.loadFBsdk();
  },

  mounted() {
    this.initFB();
  },

  methods: {
    startLogin() {
      this.hasLoginStarted = true;
      this.tryFBlogin();
    },

    setPageName({ name }) {
      this.$v.selectedPage.$touch();
      this.pageName = name;
    },

    initChannelAuth(channel) {
      if (channel === 'facebook') {
        this.loadFBsdk();
      }
    },

    initFB() {
      if (window.fbSDKLoaded === undefined) {
        window.fbAsyncInit = () => {
          FB.init({
            appId: window.chatwootConfig.fbAppId,
            xfbml: true,
            version: window.chatwootConfig.fbApiVersion,
            status: true,
          });
          window.fbSDKLoaded = true;
          FB.AppEvents.logPageView();
        };
      }
    },

    loadFBsdk() {
      ((d, s, id) => {
        let js;
        // eslint-disable-next-line
        const fjs = (js = d.getElementsByTagName(s)[0]);
        if (d.getElementById(id)) {
          return;
        }
        js = d.createElement(s);
        js.id = id;
        js.src = '//connect.facebook.net/en_US/sdk.js';
        fjs.parentNode.insertBefore(js, fjs);
      })(document, 'script', 'facebook-jssdk');
    },

    tryFBlogin() {
      FB.login(
        response => {
          if (response.status === 'connected') {
            this.saveUserToken(response.authResponse.accessToken);
          } else if (response.status === 'not_authorized') {
            // The person is logged into Facebook, but not your app.
            this.emptyStateMessage = this.$t(
              'INBOX_MGMT.DETAILS.ERROR_FB_AUTH'
            );
          } else {
            // The person is not logged into Facebook, so we're not sure if
            // they are logged into this app or not.
            this.emptyStateMessage = this.$t(
              'INBOX_MGMT.DETAILS.ERROR_FB_AUTH'
            );
          }
        },
        {
          scope:
            'public_profile,email',
        }
      );
    },

    async saveUserToken(token) {
      // also save the businees account ID and phone number ID on this success in provider config.
      try {
        // save response in account channel::whatsapp account
      } catch (error) {
        // Ignore error
      }
    },
  },
};
</script>
