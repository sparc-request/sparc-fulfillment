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

module SparcHelper
  def sparc_sends_notification_post(params=valid_params)
    # Generate the proper Basic Auth headers using the existing defined helper
    auth_headers = http_login_headers(ENV['CWF_API_USERNAME'], ENV['CWF_API_PASSWORD'])
    
    # Rails 7 Fix: Explicitly pass `as: :json` 
    post '/v1/notifications.json', params: params, as: :json, headers: auth_headers
  end

  def load_protocol_1_json
    file  = ::Rails.root.join('vcr_cassettes', 'reusable', 'sparc_api', 'get_protocol_1.yml')
    yaml  = YAML.unsafe_load_file(file)

    yaml["http_interactions"][0]["response"]["body"]["string"]
  end

  def load_service_1_json
    file  = ::Rails.root.join('vcr_cassettes', 'reusable', 'sparc_api', 'get_service_1.yml')
    yaml  = YAML.unsafe_load_file(file)

    yaml["http_interactions"][0]["response"]["body"]["string"]
  end

  def load_sub_service_request_1_json
    file  = ::Rails.root.join('vcr_cassettes', 'reusable', 'sparc_api', 'get_sub_service_request_1.yml')
    yaml  = YAML.unsafe_load_file(file)

    yaml["http_interactions"][0]["response"]["body"]["string"]
  end

  private

  def valid_params
    notification = build(:notification_protocol_create)

    {
      notification: {
        sparc_id: notification.sparc_id,
        kind: notification.kind,
        action: notification.action,
        callback_url: notification.callback_url
      }
    }
  end
end

RSpec.configure do |config|

  config.around(:each, sparc_api: :get_protocol_1) do |example|
    VCR.configure { |c| c.unignore_hosts 'localhost', '127.0.0.1' }
    begin
      VCR.use_cassette('reusable/sparc_api/get_protocol_1', match_requests_on: [:host]) do
        example.run
      end
    ensure
      VCR.configure { |c| c.ignore_localhost = true }
    end
  end

  config.around(:each, sparc_api: :get_service_1) do |example|
    VCR.configure { |c| c.unignore_hosts 'localhost', '127.0.0.1' }
    begin
      VCR.use_cassette('reusable/sparc_api/get_service_1', match_requests_on: [:host]) do
        example.run
      end
    ensure
      VCR.configure { |c| c.ignore_localhost = true }
    end
  end

  config.around(:each, sparc_api: :get_sub_service_request_1) do |example|
    VCR.configure { |c| c.unignore_hosts 'localhost', '127.0.0.1' }
    begin
      VCR.use_cassette('reusable/sparc_api/get_sub_service_request_1') do
        example.run
      end
    ensure
      VCR.configure { |c| c.ignore_localhost = true }
    end
  end

  config.around(:each, sparc_api: :get_service_components_1) do |example|
    VCR.configure { |c| c.unignore_hosts 'localhost', '127.0.0.1' }
    begin
      VCR.use_cassette('reusable/sparc_api/get_service_components_1', match_requests_on: [:method, :path, :query]) do
        example.run
      end
    ensure
      VCR.configure { |c| c.ignore_localhost = true }
    end
  end

  config.before(:each, sparc_api: :unavailable) do
    stub_request(:get, /localhost:5000/).to_return(status: 500)
  end
end
