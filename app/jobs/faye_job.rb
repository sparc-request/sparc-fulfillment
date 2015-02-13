class FayeJob < Struct.new(:protocol_id)

  class FayeUnavailable < StandardError
  end

  def self.enqueue(protocol_id)
    job = new(protocol_id)

    Delayed::Job.enqueue job, queue: 'faye'
  end

  def perform
    channels.each do |channel|
      message = {
        channel: channel,
        data: params,
        ext: { auth_token: ENV.fetch('FAYE_TOKEN') }
      }.to_json

      Net::HTTP.post_form uri, message: message
    end
  end

  def error(job, exception)
    @exception = exception
  end

  def max_attempts
    5
  end

  private

  def protocol
    @protocol ||= Protocol.find(protocol_id)
  end

  def params
    { protocol_id: protocol.id }
  end

  def channels
    ['/protocols', "/protocol_#{protocol.id}"]
  end

  def uri
    URI.parse("http://#{ENV.fetch('CWF_FAYE_HOST')}/faye")
  end
end
