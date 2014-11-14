module SparcHelper

	def sparc_sends_protocol_post
		post '/v1/protocols.json', params
	end

	private

	def params
		{
			id: 1,
			ssr_id: 1
		}
	end
end