class SubServiceRequestUpdaterJob < Struct.new(:sub_service_request_id)

  class SparcApiError < StandardError
  end

  def self.enqueue(sub_service_request_id)
    job = new(sub_service_request_id)

    Delayed::Job.enqueue job, queue: 'sparc_api_requests'
  end

  def perform
    RestClient.get(url, params) { |response, request, result, &block|
      raise SparcApiError unless response.code == 200

      SubServiceRequestUpdater.new(response, sub_service_request_id).import!
    }
  end

  private

  def params
    { accept: :json }
  end

  def url
    "#{protocol}://#{ENV['SPARC_API_USERNAME']}:#{ENV['SPARC_API_PASSWORD']}@#{ENV['SPARC_API_HOST']}/#{sparc_api_version}/sub_service_requests/#{sub_service_request_id}.json"
  end

  def protocol
    'http'
  end

  def sparc_api_version
    'v1'
  end
end
