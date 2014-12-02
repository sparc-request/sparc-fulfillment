class ProtocolUpdaterJob < Struct.new(:protocol_id)

  class SparcApiError < StandardError
  end

  def self.enqueue(protocol_id)
    job = new(protocol_id)

    Delayed::Job.enqueue job, queue: 'sparc_api_requests'
  end

  def perform
    RestClient.get(url, params) { |response, request, result, &block|
      raise SparcApiError unless response.code == 200

      RemoteObjectUpdater.new(response, protocol_id).import!
    }
  end

  private

  def params
    { accept: :json }
  end

  def url
    "#{http_protocol}://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/#{sparc_api_version}/protocols/#{protocol.sparc_id}.json"
  end

  def http_protocol
    'http'
  end

  def sparc_api_version
    'v1'
  end

  def protocol
    @protocol ||= Protocol.find protocol_id
  end
end
