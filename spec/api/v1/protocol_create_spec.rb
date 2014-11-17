require 'rails_helper'

RSpec.describe 'CWFSPARC::APIv1', type: :request,
																debug_response: true do

	describe 'POST /v1/protocols.json' do

		context 'success' do

			before { sparc_sends_protocol_post }

			it 'should respond with an HTTP status of: 201' do
				expect(response.status).to eq(201)
			end

			it 'should respond with content-type: application/json' do
				expect(response.content_type).to eq('application/json')
			end
    end

    context 'failure' do

      context 'missing params' do

        describe ':id missing' do

          it 'should respond with an HTTP status of: 400' do

            bad_params = { ssr_id: 1 }

            sparc_sends_protocol_post(bad_params)

            expect(response.status).to eq(400)
          end
        end

        describe ':ssr_id missing' do

          it 'should respond with an HTTP status of: 400' do

            bad_params = { id: 1 }

            sparc_sends_protocol_post(bad_params)

            expect(response.status).to eq(400)
          end
        end
      end

      context 'invalid params' do

        describe ':id' do

          it 'must be type: Integer' do

            bad_params = { id: '1a', ssr_id: 1 }
            
            sparc_sends_protocol_post(bad_params)

            expect(response.status).to eq(400)
          end
        end

        describe ':ssr_id' do

          it 'must be type: Integer' do

            bad_params = { id: 1, ssr_id: '1a' }

            sparc_sends_protocol_post(bad_params)

            expect(response.status).to eq(400)
          end
        end

        describe 'empty :ssr_id' do

          it 'must not be empty' do

            bad_params = { id: 1, ssr_id: '' }

            sparc_sends_protocol_post(bad_params)

            expect(response.status).to eq(400)
          end
        end
      end
    end
	end
end