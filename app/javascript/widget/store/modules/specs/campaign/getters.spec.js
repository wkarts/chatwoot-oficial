import { getters } from '../../campaign';
import { campaigns } from './data';

describe('#getters', () => {
  it('fetchCampaigns', () => {
    const state = {
      records: campaigns,
    };
    expect(getters.fetchCampaigns(state)).toEqual([
      {
        id: 1,
        title: 'Welcome',
        description: null,
        account_id: 1,
        inbox: {
          id: 37,
          channel_id: 1,
          name: 'ABrand',
          channel_type: 'Channel::WebWidget',
        },
        sender: {
          account_id: 1,
          availability_status: 'offline',
          confirmed: true,
          email: 'sojan@chatwoot.com',
          available_name: 'Sojan',
          id: 10,
          name: 'Sojan',
        },
        message: 'Hey, What brings you today',
        enabled: true,
        trigger_rules: {
          url: 'https://github.com',
          time_on_page: 10,
        },
        created_at: '2021-05-03T04:53:36.354Z',
        updated_at: '2021-05-03T04:53:36.354Z',
      },
      {
        id: 11,
        title: 'Onboarding Campaign',
        description: null,
        account_id: 1,
        inbox: {
          id: 37,
          channel_id: 1,
          name: 'GitX',
          channel_type: 'Channel::WebWidget',
        },
        sender: {
          account_id: 1,
          availability_status: 'offline',
          confirmed: true,
          email: 'sojan@chatwoot.com',
          available_name: 'Sojan',
          id: 10,
        },
        message: 'Begin your onboarding campaign with a welcome message',
        enabled: true,
        trigger_rules: {
          url: 'https://chatwoot.com',
          time_on_page: '20',
        },
        created_at: '2021-05-03T08:15:35.828Z',
        updated_at: '2021-05-03T08:15:35.828Z',
      },
      {
        id: 12,
        title: 'Thanks',
        description: null,
        account_id: 1,
        inbox: {
          id: 37,
          channel_id: 1,
          name: 'ABrand',
          channel_type: 'Channel::WebWidget',
        },
        sender: {
          account_id: 1,
          availability_status: 'offline',
          confirmed: true,
          email: 'nithin@chatwoot.com',
          available_name: 'Nithin',
        },
        message: 'Thanks for coming to the show. How may I help you?',
        enabled: false,
        trigger_rules: {
          url: 'https://noshow.com',
          time_on_page: 10,
        },
        created_at: '2021-05-03T10:22:51.025Z',
        updated_at: '2021-05-03T10:22:51.025Z',
      },
    ]);
  });
});
