RSpec.configure do |config|

  config.before(:each, type: :feature) do
    sign_in
  end
  config.after(:each, type: :feature) do
    Warden.test_reset! 
  end
end