require 'rails_helper'

RSpec.describe 'CWFSPARC::APIv1', type: :request, debug_response: true do

  describe 'authentication' do

    context 'success' do

      before do
        http_login(ENV['SPARC_API_USERNAME'], ENV['SPARC_API_PASSWORD'])

        post '/v1/notifications.json', params, @env
      end

      it 'should allow the request' do
        expect(response.code).to eq('201')
      end
    end

    context 'failure' do

      context 'bad username' do

        before do
          bad_username = 'bad_username'

          http_login(bad_username, ENV['SPARC_PASSWORD'])

          post '/v1/notifications.json', params, @env
        end

        it 'should not allow the request' do
          expect(response.code).to eq('401')
        end

        it 'should not respond' do
          expect(response.body).to be_empty
        end
      end

      context 'bad password' do

        before do
          bad_password = 'bad_password'

          http_login(bad_password, ENV['SPARC_PASSWORD'])

          post '/v1/notifications.json', params, @env
        end

        it 'should not allow the request' do
          expect(response.code).to eq('401')
        end

        it 'should not respond' do
          expect(response.body).to be_empty
        end
      end
    end
  end

  def params
    {
      notification: {
        sparc_id: 1,
        kind: 'SubServiceRequest',
        action: 'create',
        callback_url: 'http://localhost:5000/sub_service_requests/1.json'
      }
    }
  end
end
