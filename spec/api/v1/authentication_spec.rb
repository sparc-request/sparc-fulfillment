require 'rails_helper'

RSpec.describe 'CWFSPARC::APIv1', type: :request,
                                  debug_response: true do

  describe 'authentication' do

    context 'success' do

      before do
        http_login(ENV['SPARC_USERNAME'], ENV['SPARC_PASSWORD'])

        post '/v1/protocols.json', { protocol_id: 1, sub_service_request_id: 1 }, @env
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

          post '/v1/protocols.json', { protocol_id: 1, sub_service_request_id: 1 }, @env
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

          post '/v1/protocols.json', { protocol_id: 1, sub_service_request_id: 1 }, @env
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
end
