RSpec.configure do |config|
	
	config.after(:each, debug_response: true) do
		Rails.logger.debug "Response:\n#{response.body}"
	end
end