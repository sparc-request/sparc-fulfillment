module SparcHelper

  def sparc_sends_protocol_post(params=valid_params)
    http_login(ENV['SPARC_API_USERNAME'], ENV['SPARC_API_PASSWORD'])

    post '/v1/protocols.json', params, @env
  end

  private

  def valid_params
    {
      protocol_id: 1,
      sub_service_request_id: 1
    }
  end
end
