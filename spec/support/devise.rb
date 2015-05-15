module DeviseHelpers

  def sign_in
    user = create(:identity)

    login_as(user, scope: :user, run_callbacks: false)
  end
end

module ControllerMacros

  def login_user

    before(:each) do
      @request.env['devise.mapping']  = Devise.mappings[:user]
      user                            = create(:identity)

      sign_in user
    end
  end
end

RSpec.configure do |config|

  config.include Warden::Test::Helpers
  config.include DeviseHelpers, type: :feature
  config.include Devise::TestHelpers, type: :controller
  config.extend ControllerMacros, type: :controller

  config.before(:each, type: :feature) do
    Warden.test_mode!

    sign_in
  end

  config.after(:each, type: :feature) do
    Warden.test_reset!
  end
end
