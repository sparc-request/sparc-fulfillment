RSpec.configure do |config|

  config.before(:each, sparc_api: :available) do
    stub_request(:get, /sparc.musc.edu/).to_return(status: 200)
  end

  config.before(:each, sparc_api: :unavailable) do
    stub_request(:get, /sparc.musc.edu/).to_return(status: 500)
  end
end
