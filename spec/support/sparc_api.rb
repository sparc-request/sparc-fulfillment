module SparcHelper

  def sparc_sends_notification_post(params=valid_params)
    http_login(ENV['SPARC_API_USERNAME'], ENV['SPARC_API_PASSWORD'])

    post '/v1/notifications.json', params, @env
  end

  def load_protocol_1_json
    file  = ::Rails.root.join('vcr_cassettes', 'reusable', 'sparc_api', 'get_protocol_1.yml')
    yaml  = YAML.load_file file

    yaml["http_interactions"][0]["response"]["body"]["string"]
  end

  def load_service_1_json
    file  = ::Rails.root.join('vcr_cassettes', 'reusable', 'sparc_api', 'get_service_1.yml')
    yaml  = YAML.load_file file

    yaml["http_interactions"][0]["response"]["body"]["string"]
  end

  def load_sub_service_request_1_json
    file  = ::Rails.root.join('vcr_cassettes', 'reusable', 'sparc_api', 'get_sub_service_request_1.yml')
    yaml  = YAML.load_file file

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

  config.before(:each, sparc_api: :get_protocol_1) do
    VCR.insert_cassette('reusable/sparc_api/get_protocol_1', match_requests_on: [:host])
  end

  config.before(:each, sparc_api: :get_service_1) do
    VCR.insert_cassette('reusable/sparc_api/get_service_1', match_requests_on: [:host])
  end

  config.before(:each, sparc_api: :get_sub_service_request_1) do
    VCR.insert_cassette('reusable/sparc_api/get_sub_service_request_1')
  end

  config.before(:each, sparc_api: :get_service_level_component_1) do
    VCR.insert_cassette('reusable/sparc_api/get_service_level_component_1')
  end

  config.before(:each, sparc_api: :get_project_role_1) do
    VCR.insert_cassette('reusable/sparc_api/get_project_role_1')
  end

  config.before(:each, sparc_api: :unavailable) do
    stub_request(:get, /localhost:5000/).to_return(status: 500)
  end
end
