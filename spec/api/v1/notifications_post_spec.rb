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
