RSpec.configure do |config|

  config.before(:each, sparc_api: :get_protocol_1) do
    VCR.insert_cassette('reusable/sparc_api/get_protocol_1', match_requests_on: [:host])
  end

  config.before(:each, sparc_api: :get_service_1) do
    VCR.insert_cassette('reusable/sparc_api/get_service_1', match_requests_on: [:host])
  end

  config.before(:each, sparc_api: :unavailable) do
    stub_request(:get, /sparc.musc.edu/).to_return(status: 500)
  end
end
