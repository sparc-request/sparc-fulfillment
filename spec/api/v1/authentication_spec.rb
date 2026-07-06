# Copyright © 2011-2023 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require 'rails_helper'

RSpec.describe 'CWFSPARC::APIv1', type: :request, debug_response: true do
  describe 'authentication' do
    let(:valid_params) do
      {
        notification: {
          sparc_id: 1,
          kind: 'SubServiceRequest',
          action: 'create',
          callback_url: 'http://localhost:5000/sub_service_requests/1.json'
        }
      }
    end

    context 'success' do
      it 'allows the request' do
        auth_headers = http_login_headers(ENV['CWF_API_USERNAME'], ENV['CWF_API_PASSWORD'])
        
        post '/v1/notifications.json', params: valid_params, headers: auth_headers
        
        expect(response).to have_http_status(:created) # 201
      end
    end

    context 'failure' do
      context 'with bad username' do
        it 'does not allow the request and returns empty body' do
          auth_headers = http_login_headers('bad_username', ENV['CWF_API_PASSWORD'])
          
          post '/v1/notifications.json', params: valid_params, headers: auth_headers
          
          expect(response).to have_http_status(:unauthorized) # 401
          expect(response.body).to be_empty
        end
      end

      context 'with bad password' do
        it 'does not allow the request and returns empty body' do
          auth_headers = http_login_headers(ENV['CWF_API_USERNAME'], 'bad_password')
          
          post '/v1/notifications.json', params: valid_params, headers: auth_headers
          
          expect(response).to have_http_status(:unauthorized) # 401
          expect(response.body).to be_empty
        end
      end
    end
  end
end
