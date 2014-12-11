include Warden::Test::Helpers

module DeviseHelpers

  def sign_in
    Warden.test_mode!
    user = create(:user)
    login_as(user, :scope => :user, :run_callbacks => false)
  end
end