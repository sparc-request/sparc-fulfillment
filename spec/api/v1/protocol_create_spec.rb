require 'rails_helper'

RSpec.describe 'CWFSPARC::API', type: :request,
																debug_response: true do

	describe 'POST /v1/protocols.json' do

		context 'success' do

			before { sparc_sends_protocol_post }

			it 'should respond with an HTTP status of: 200' do
				expect(response.status).to eq(201)
			end

			it 'should respond with content-type: application/json' do
				expect(response.content_type).to eq('application/json')
			end
    end
	end
end