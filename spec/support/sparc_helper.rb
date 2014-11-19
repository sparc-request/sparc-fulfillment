module SparcHelper

	def sparc_sends_protocol_post(params=valid_params)
		post '/v1/protocols.json', params
	end

	private

	def valid_params
		{
			protocol_id: 1,
			sub_service_request_id: 1
		}
	end
end
