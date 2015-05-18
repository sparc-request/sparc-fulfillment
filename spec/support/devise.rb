module DeviseHelpers

  def sign_in
    identity = create(:identity)

    login_as(identity, run_callbacks: false)
  end
end

module ControllerMacros

  def login_user

    before(:each) do
      @request.env['devise.mapping']  = Devise.mappings[:identity]
      identity                        = create(:identity)

      sign_in identity
    end
  end
end

RSpec.configure do |config|

  config.include Warden::Test::Helpers
  config.include DeviseHelpers, type: :feature
  config.include Devise::TestHelpers, type: :controller
  config.extend ControllerMacros, type: :controller

  config.before(:suite) do
    Warden.test_mode!
  end

  config.before(:each) do
    sign_in
  end

  config.after(:each) do
    Warden.test_reset!
  end
end
