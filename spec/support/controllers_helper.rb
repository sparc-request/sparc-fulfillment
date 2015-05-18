module ControllerHelpers
  def sign_in(identity = create(:identity))
    allow(request.env['warden']).to receive(:authenticate!).and_return(identity)
    allow(controller).to receive(:current_identity).and_return(identity)
  end
end

RSpec.configure do |config|
  config.include Devise::TestHelpers, :type => :controller
  config.include ControllerHelpers, :type => :controller
end
