RSpec.configure do |config|

  config.before(:each) do
    sign_in
  end
  config.after(:each) do
    Warden.test_reset! 
  end
end