class FayeClient

  def initialize(data, channels)
    @data     = data
    @channels = channels
  end

  def publish
    @channels.each do |channel|
      message = {
        channel: channel,
        data: @data,
        ext: { auth_token: ENV.fetch('FAYE_TOKEN') }
      }.to_json

      Net::HTTP.post_form uri, message: message
    end
  end

  private

  def uri
    URI.parse("#{ENV.fetch('GLOBAL_SCHEME')}://#{ENV.fetch('CWF_FAYE_HOST')}/faye")
  end
end
