module DeviseHelpers

  def sign_in
    user = create(:user)

    login_as(user, scope: :user, run_callbacks: false)
  end
end


RSpec.configure do |config|

  config.include Warden::Test::Helpers
  config.include DeviseHelpers, type: :feature

  config.before(:each, type: :feature) do
    Warden.test_mode!

    sign_in
  end

  config.after(:each, type: :feature) do
    Warden.test_reset!
  end
end
