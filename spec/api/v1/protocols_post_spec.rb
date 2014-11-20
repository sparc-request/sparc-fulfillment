require 'rails_helper'

RSpec.describe 'CWFSPARC::APIv1', type: :request,
                                  debug_response: true do

  describe 'POST /v1/protocols.json' do

    context 'success' do

      before do
        sparc_sends_protocol_post
      end

      it 'should respond with an HTTP status of: 201' do
        expect(response.status).to eq(201)
      end

      it 'should respond with content-type: application/json' do
        expect(response.content_type).to eq('application/json')
      end
    end

    context 'failure' do

      context 'missing params' do

        describe ':protocol_id missing' do

          it 'should respond with an HTTP status of: 400' do

            bad_params = { sub_service_request_id: 1 }

            sparc_sends_protocol_post(bad_params)

            expect(response.status).to eq(400)
          end
        end

        describe ':sub_service_request_id missing' do

          it 'should respond with an HTTP status of: 400' do

            bad_params = { protocol_id: 1 }

            sparc_sends_protocol_post(bad_params)

            expect(response.status).to eq(400)
          end
        end
      end

      context 'invalid params' do

        describe ':protocol_id' do

          it 'must be type: Integer' do

            bad_params = { protocol_id: '1a', sub_service_request_id: 1 }

            sparc_sends_protocol_post(bad_params)

            expect(response.status).to eq(400)
          end
        end

        describe ':sub_service_request_id' do

          it 'must be type: Integer' do

            bad_params = { iprotocol_idd: 1, sub_service_request_id: '1a' }

            sparc_sends_protocol_post(bad_params)

            expect(response.status).to eq(400)
          end
        end

        describe 'empty :sub_service_request_id' do

          it 'must not be empty' do

            bad_params = { protocol_id: 1, sub_service_request_id: '' }

            sparc_sends_protocol_post(bad_params)

            expect(response.status).to eq(400)
          end
        end
      end
    end
  end
end
