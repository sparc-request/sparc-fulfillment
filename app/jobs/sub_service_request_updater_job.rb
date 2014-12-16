class SubServiceRequestUpdaterJob < Struct.new(:sparc_id, :callback_url)

  class SparcApiError < StandardError
  end

  def self.enqueue(sparc_id, callback_url)
    job = new(sparc_id, callback_url)

    Delayed::Job.enqueue job, queue: 'sparc_api_requests'
  end

  def perform
    RemoteObjectUpdater.new(remote_protocol_json, local_protocol).import!
  end

  private

  def remote_sub_service_request_json
    @remote_sub_service_request ||= get_remote_object(callback_url)
  end

  def remote_service_request_json
    service_request_callback_url = remote_sub_service_request_json['sub_service_request']['service_request']['callback_url']

    @remote_service_request ||= get_remote_object(service_request_callback_url)
  end

  def remote_protocol_json
    protocol_callback_url = remote_service_request_json['service_request']['protocol']['callback_url']

    @remote_protocol ||= get_remote_object(protocol_callback_url)
  end

  def local_protocol
    remote_protocol_sparc_id = remote_protocol_json['protocol']['sparc_id']

    @local_protocol ||= Protocol.where(sparc_id: remote_protocol_sparc_id).first
  end

  def get_remote_object(url)
    qualified_url = qualify_url(url)

    RestClient.get(qualified_url, params) { |response, request, result, &block|
      raise SparcApiError unless response.code == 200

      @response = response
    }

    parse_json @response
  end

  def qualify_url(url)
    uri           = URI(url)
    uri.user      = ENV['SPARC_API_USERNAME']
    uri.password  = ENV['SPARC_API_PASSWORD']
    uri.query     = 'depth=full_with_shallow_reflections'

    uri.to_s
  end

  def params
    { accept: :json }
  end

  def parse_json(response)
    Yajl::Parser.parse response
  end
end
