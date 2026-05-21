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

require 'selenium/webdriver'

# ====================================================================
# 1. THE REMOTE DRIVER MUTATION
# We bypass ActionDispatch's wrapper and define the pure Selenium 4 driver.
# ====================================================================
Capybara.register_driver :docker_chrome_headless do |app|
  selenium_url = begin
                   selenium_host = Addrinfo.getaddrinfo('selenium_chrome', 4444).first.ip_address
                   "http://#{selenium_host}:4444/wd/hub"
                 rescue Socket::ResolutionError
                   'http://selenium_chrome:4444/wd/hub'
                 end

  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new')
  options.add_argument('--window-size=1920,1080')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-gpu')

  # In Selenium 4, we pass the Options instance directly into capabilities
  Capybara::Selenium::Driver.new(
    app,
    browser: :remote,
    url: selenium_url,
    capabilities: options
  )
end

RSpec.configure do |config|
  $puma_warmed_up = false

  config.before(:each, type: :system) do
    # 2. Tell Rails to use our custom, explicitly defined grid driver
    driven_by :docker_chrome_headless

    # 3. Re-establish Capybara server coordinate mappings
    Capybara.server_host = '0.0.0.0'
    Capybara.server_port = 3002
    Capybara.app_host = ENV['CAPYBARA_APP_HOST'] || 'http://cwf_web:3002'

    # 4. THE PUMA COLD-BOOT HOOK
    unless $puma_warmed_up
      puts "\n🦖 Cold-booting the 20-year-old Puma monolith as a System Spec... brace yourself."
      visit '/'
      expect(page).to have_css('body', wait: 60)
      
      $puma_warmed_up = true
      puts "✅ Puma is awake. Transactional boundaries verified. Initiating lightspeed..."
    end
  end
end