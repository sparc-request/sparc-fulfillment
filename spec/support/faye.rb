RSpec.configure do |config|
  config.before(:each, faye: true) do
    stub_request(:post, /faye.musc.edu/).to_return(status: 200)
  end
end