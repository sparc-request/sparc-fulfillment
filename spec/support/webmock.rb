WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|

  config.after(:each) do
    WebMock.reset!
  end
end
