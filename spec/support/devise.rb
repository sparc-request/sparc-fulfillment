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
    
    if respond_to?(:visit)
      visit '/'
      
      if page.has_css?('#outsideUserLogin', wait: 15)
        find('#outsideUserLogin').click
      end

      fill_in 'identity_ldap_uid', with: identity.ldap_uid
      fill_in 'identity_password', with: identity.password || 'password'
      click_button 'Sign In'

      # Wait for the user profile to appear in the navbar. This guarantees we don't proceed until the session is fully established.
      expect(page).to have_css('.nav-item.profile', wait: 15)
    else
      sign_in(identity)
      login_as(identity, scope: :identity)
    end
    
    identity
  end
end

module ControllerMacros
  def login_user
    before(:each) do
      @request.env['devise.mapping'] = Devise.mappings[:identity]
      auto_login_identity
    end
  end
end

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :feature
  config.include Devise::Test::IntegrationHelpers, type: :system
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view

  config.include CustomAuthHelpers, type: :feature
  config.include CustomAuthHelpers, type: :system
  config.include CustomAuthHelpers, type: :model
  config.extend ControllerMacros, type: :controller

  config.include Warden::Test::Helpers
  
  config.before(:suite) do
    Warden.test_mode!
  end

  config.before(:each, type: :feature) do
    auto_login_identity
  end

  config.before(:each, type: :system) do
    auto_login_identity
  end

  config.after(:each) do
    Warden.test_reset!
  end
end
