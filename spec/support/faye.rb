RSpec.configure do |config|

  config.before(:each) do
    stub_request(:post, /localhost\:9292/).to_return(status: 200)
  end
end
