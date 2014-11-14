module SparcHelper

	def sparc_sends_protocol_post(params=valid_params)
		post '/v1/protocols.json', params
	end

	private

	def valid_params
		{
			id: 1,
			ssr_id: 1
		}
	end
end