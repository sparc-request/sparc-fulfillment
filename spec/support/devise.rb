# Copyright © 2011-2023 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

module CustomAuthHelpers
  def auto_login_identity(identity = nil)
    # Never trust Identity.first. Always guarantee a known password.
    identity ||= create(:identity, password: 'password', password_confirmation: 'password')
    @logged_in_identity = identity
    
    # 1. Instantly authenticate at the Rack level (bypasses LDAP and UI entirely)
    sign_in(identity) if respond_to?(:sign_in) # Devise helper
    login_as(identity, scope: :identity)       # Warden helper
    
    # 2. For browser-based system tests, simply navigate directly to the app
    if respond_to?(:visit)
      visit '/'
      
      # Wait for the user profile to appear to guarantee the session was recognized
      expect(page).to have_css('.nav-item.profile', wait: 15)
    end
    
    identity
  end
end

module ControllerMacros
  def login_user
    before(:each) do
      # Controller specs bypass Rack middleware and require this mapping.
      # Request specs route through Rack, so we conditionally apply it only for controllers.
      if RSpec.current_example.metadata[:type] == :controller
        @request.env['devise.mapping'] = Devise.mappings[:identity]
      end

      auto_login_identity
    end
  end
end

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :system
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view

  config.include CustomAuthHelpers, type: :feature
  config.include CustomAuthHelpers, type: :system
  config.include CustomAuthHelpers, type: :model
  config.include CustomAuthHelpers, type: :controller
  config.include CustomAuthHelpers, type: :request

  config.include Warden::Test::Helpers

  config.extend ControllerMacros, type: :controller
  
  config.before(:suite) do
    Warden.test_mode!
  end

  config.before(:each, type: :system) do
    auto_login_identity
  end

  config.after(:each) do
    Warden.test_reset!
  end
end
