class ProtocolWorkerJob < Struct.new(:protocol_id, :sub_service_request_id)

  class SparcApiError < StandardError
  end

  def self.enqueue(protocol_id, sub_service_request_id)
    job = new(protocol_id, sub_service_request_id)

    Delayed::Job.enqueue job, queue: 'sparc_protocol_updater'
  end

  def perform
    RestClient.get(url, params) { |response, request, result, &block| raise SparcApiError unless response.code == 200 }
  end

  private

  def params
    {
      params: { sub_service_request_id: sub_service_request_id },
      accept: :json
    }
  end

  def url
    "https://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/#{sparc_api_version}/protocols/#{protocol_id}.json"
  end

  def sparc_api_version
    'v1'
  end
end
