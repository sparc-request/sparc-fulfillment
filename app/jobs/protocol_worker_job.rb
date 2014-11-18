class ProtocolWorkerJob < Struct.new(:protocol_id, :ssr_id, :new_record)

  class SparcApiError < StandardError
  end

  def perform
    if new_record
      RestClient.get(url, params) { |response, request, result, &block|
        raise SparcApiError unless response.code == 200
        puts response.inspect
      }
    else
      # response = RestClient.patch url, {id: protocol_id}, content_type: 'application.json'
    end
  end

  def self.enqueue protocol_id, ssr_id, new_record
    job = new protocol_id, ssr_id, new_record
    Delayed::Job.enqueue job, queue: 'sparc_protocol_updater'
  end

  private

  def params
    {
      params: { ssr_id: ssr_id },
      accept: :json
    }

  end

  def url
    "https://sparc.musc.edu/v1/protocols/#{protocol_id}.json"
  end
end
