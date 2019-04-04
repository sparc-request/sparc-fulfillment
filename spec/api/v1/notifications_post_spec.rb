# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

  describe 'POST /v1/notifications.json' do

    context 'success' do

      before do
        sparc_sends_notification_post
      end

      it 'should respond with an HTTP status of: 201' do
        expect(response.status).to eq(201)
      end

      it 'should respond with content-type: application/json' do
        expect(response.content_type).to eq('application/json')
      end

      it 'should create a Notification' do
        expected_notification = Notification.first

        expect(Notification.count).to eq(1)
        expect(expected_notification.sparc_id).to eq(1)
        expect(expected_notification.kind).to eq('Protocol')
        expect(expected_notification.action).to eq('create')
        expect(expected_notification.callback_url).to eq('http://localhost:5000/v1/protocols/1.json')
      end
    end

    context 'failure' do

      context 'missing params' do

        describe ':id missing' do

          it 'should respond with an HTTP status of: 400' do

            bad_params = { action: 'create', callback_url: 'http://localhost:5000/v1/sub_service_requests/1.json' }

            sparc_sends_notification_post(bad_params)

            expect(response.status).to eq(400)
          end
        end

        describe ':action missing' do

          it 'should respond with an HTTP status of: 400' do

            bad_params = { id: 1, callback_url: 'http://localhost:5000/v1/sub_service_requests/1.json' }

            sparc_sends_notification_post(bad_params)

            expect(response.status).to eq(400)
          end
        end

        describe ':callback_url missing' do

          it 'should respond with an HTTP status of: 400' do

            bad_params = { id: 1, action: 'create' }

            sparc_sends_notification_post(bad_params)

            expect(response.status).to eq(400)
          end
        end
      end

      context 'invalid params' do

        describe ':id' do

          it 'must be type: Integer' do

            bad_params = { id: '1a', action: 'create', callback_url: 'http://localhost:5000/v1/sub_service_requests/1.json' }

            sparc_sends_notification_post(bad_params)

            expect(response.status).to eq(400)
          end
        end

        describe ':action' do

          it 'must be either: create or update' do

            bad_params = { id: '1a', action: 'delete', callback_url: 'http://localhost:5000/v1/sub_service_requests/1.json' }

            sparc_sends_notification_post(bad_params)

            expect(response.status).to eq(400)
          end
        end
      end
    end
  end
end
