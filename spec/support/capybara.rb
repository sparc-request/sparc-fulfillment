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

# require 'selenium-webdriver'

# Capybara.default_max_wait_time = 5

# Capybara.register_driver :firefox_headless do |app|
#   options = Selenium::WebDriver::Firefox::Options.new

#   if ENV['MOZ_HEADLESS']
#     options.add_argument('--headless')
#   end

#   Capybara::Selenium::Driver.new(app, browser: :firefox, options: options)
# end

# Capybara.javascript_driver = :firefox_headless

# require 'capybara/rspec'
# require 'selenium-webdriver'

# RSpec.configure do |config|
#   config.before(:each, type: :feature) do
#     Capybara.default_max_wait_time = 5
#     # Check if we are running in a Dockerized environment
#     if ENV['DOCKERIZED_TESTS']
#       # Point Capybara to the Selenium standalone container
#       Capybara.app_host = "http://cwf_web:3001" # Use the internal Docker service name and port of your Rails app
#       Capybara.server_host = "0.0.0.0" # Bind to all interfaces
#       # Capybara.server_port = 3001 # Use the port exposed by the Rails container / commented out to allow Capybara to choose its own open port
#       Capybara.register_driver :firefox_headless do |app|
#         options = Selenium::WebDriver::Firefox::Options.new
#         options.add_argument('--headless')
#         #options.add_argument('--disable-gpu')
#         #options.add_argument('--disable-dev-shm-usage')

#         Capybara::Selenium::Driver.new(
#           app,
#           browser: :remote,
#           url: ENV.fetch('SELENIUM_URL', 'http://localhost:4444/wd/hub'),
#           options: options
#         )
#       end
#       Capybara.default_driver = :firefox_headless
#       Capybara.javascript_driver = :firefox_headless
#     else
#       # Configuration for running tests on your local machine
#       Capybara.app_host = "http://localhost:3001"
#     end
#   end
# end

require 'capybara/rspec'
require 'selenium/webdriver'

RSpec.configure do |config|
  config.before(:each, type: :feature) do
    # Set default max wait time to 5 for flaky tests
    Capybara.default_max_wait_time = 5
    # Set the host for the application, accessible from the Selenium container
    Capybara.app_host = ENV['CAPYBARA_APP_HOST'] || 'http://localhost:3002'
    # Make sure Capybara can bind to an accessible interface, not just 127.0.0.1
    Capybara.server_host = '0.0.0.0'
    Capybara.server_port = 3002
    # Point Capybara to the remote Selenium server (e.g., 'selenium-hub' is the service name)
    Capybara.register_driver :firefox_headless do |app|
      options = Selenium::WebDriver::Firefox::Options.new
      options.add_argument('--headless')
      options.add_argument('--window-size=1920,1080')
      options.add_argument('--no-sandbox')

      selenium_host = begin
                        Addrinfo.getaddrinfo('selenium_firefox', 4444).first.ip_address
                      rescue Socket::ResolutionError
                        'selenium_firefox' # Fallback
                      end

      driver = Capybara::Selenium::Driver.new(
        app,
        browser: :remote,
        options: options,
        url: "http://#{selenium_host}:4444/wd/hub"
      )

      driver.browser.manage.window.size = Selenium::WebDriver::Dimension.new(1920, 1080)

      driver
    end
    Capybara.default_driver = :firefox_headless
    Capybara.javascript_driver = :firefox_headless
  end

  config.after(:each, type: :feature) do
    begin
      errors = page.driver.browser.logs.get(:browser)
      if errors.present?
        puts "JavaScript Errors in #{+example.location}:"
        errors.each { |e| puts e.message }
      end
    rescue NoMethodError, StandardError
      # Selenium 4 Remote Drivers throw NoMethodError here. 
      # Catch it and silently move on.
    end
  end
end