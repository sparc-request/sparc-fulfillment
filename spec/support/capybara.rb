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
require 'socket'

# Now handles both Docker and CI
Capybara.register_driver :remote_chrome_headless do |app|
  # Fallback chain: CI's host first, then the Docker host
  selenium_host = ENV.fetch('SELENIUM_HOST', 'selenium_chrome')

  selenium_url = begin
                   ip = Addrinfo.getaddrinfo(selenium_host, 4444).first.ip_address
                   "http://#{ip}:4444/wd/hub"
                 rescue Socket::ResolutionError
                   "http://#{selenium_host}:4444/wd/hub"
                 end

  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new')
  options.add_argument('--window-size=1920,1080')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-gpu')

  Capybara::Selenium::Driver.new(app, browser: :remote, url: selenium_url, capabilities: options)
end

RSpec.configure do |config|
  config.before(:each, type: :system) do
    if ENV['CI']
      # 1. GITHUB ACTIONS ENVIRONMENT
      driven_by :remote_chrome_headless
      
      # Bind to all interfaces so the Docker container can reach in
      Capybara.server_host = '0.0.0.0'
      Capybara.server_port = 3002
      
      # Dynamically find the runner's IP address on the network
      runner_ip = Socket.ip_address_list.find { |ai| ai.ipv4? && !ai.ipv4_loopback? }&.ip_address || '172.17.0.1'
      
      # Tell Chrome to navigate to the runner's actual IP, not "localhost"
      Capybara.app_host = "http://#{runner_ip}:3002"
      
    elsif File.exist?('/.dockerenv')
      # 2. DOCKER ENVIRONMENT
      # Uses standard Docker network routing
      driven_by :remote_chrome_headless
      Capybara.server_host = '0.0.0.0'
      Capybara.server_port = 3002
      Capybara.app_host = ENV.fetch('CAPYBARA_APP_HOST', 'http://cwf_web:3002')
      
    else
      # 3. STANDARD LOCAL ENVIRONMENT
      # Uses Rails 7's built-in headless driver - no remote server needed!
      driven_by :selenium, using: :headless_chrome, screen_size: [1920, 1080]
      Capybara.server_host = '127.0.0.1'
      Capybara.server_port = 3002
      # app_host naturally defaults to server_host:server_port locally
    end
    
    Capybara.default_max_wait_time = 5 
  end
end