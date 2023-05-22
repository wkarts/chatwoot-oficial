require 'rails_helper'

RSpec.describe 'Enterprise Audit API', type: :request do
  let!(:account) { create(:account) }
  let!(:inbox) { create(:inbox, account: account) }
  let!(:admin) { create(:user, account: account, role: :administrator) }

  describe 'GET /api/v1/accounts/{account.id}/audit_logs' do
    context 'when it is an un-authenticated user' do
      it 'does not fetch audit logs associated with the account' do
        get "/api/v1/accounts/#{account.id}/audit_logs",
            as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when it is an authenticated normal user' do
      let(:user) { create(:user, account: account) }

      it 'fetches audit logs associated with the account' do
        get "/api/v1/accounts/#{account.id}/audit_logs",
            headers: user.create_new_auth_token,
            as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    # check for response in parse
    context 'when it is an authenticated admin user' do
      it 'returns empty array if feature is not enabled' do
        get "/api/v1/accounts/#{account.id}/audit_logs",
            headers: admin.create_new_auth_token,
            as: :json

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['audit_logs']).to eql([])
      end

      it 'fetches audit logs associated with the account' do
        account.enable_features(:audit_logs)
        account.save!

        get "/api/v1/accounts/#{account.id}/audit_logs",
            headers: admin.create_new_auth_token,
            as: :json

        expect(response).to have_http_status(:success)
        json_response = JSON.parse(response.body)
        expect(json_response['audit_logs'][0]['auditable_type']).to eql('Inbox')
        expect(json_response['audit_logs'][0]['action']).to eql('create')
        expect(json_response['audit_logs'][0]['audited_changes']['name']).to eql(inbox.name)
        expect(json_response['audit_logs'][0]['associated_id']).to eql(account.id)
        expect(json_response['current_page']).to be(1)
        expect(json_response['total_entries']).to be(1)
      end
    end
  end

  describe 'POST /sign_in' do
    let!(:account) { create(:account) }
    let!(:user) { create(:user, password: 'Password1!', account: account) }

    it 'creates a sign_in audit event' do
      params = { email: user.email, password: 'Password1!' }

      post new_user_session_url,
           params: params,
           as: :json

      expect(response).to have_http_status(:success)
      expect(response.body).to include(user.email)

      # Check if the sign_in event is created
      user.reload
      expect(user.audits.last.action).to eq('sign_in')
      expect(user.audits.last.associated_id).to eq(account.id)
      expect(user.audits.last.associated_type).to eq('Account')
    end
  end
end
