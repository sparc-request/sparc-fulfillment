RSpec.configure do |config|

  config.before(:each, sparc_api: :available) do
    VCR.insert_cassette('reusable/sparc_api', match_requests_on: [:host])
  end

  config.before(:each, sparc_api: :unavailable) do
    stub_request(:get, /sparc.musc.edu/).to_return(status: 500)
  end
end
