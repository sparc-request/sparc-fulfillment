class FayeJob < Struct.new(:object_id, :object_class)

  class FayeUnavailable < StandardError
  end

  def self.enqueue(object)
    job = new(object.id, object.class.name)

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

  def object
    @object ||= object_class.constantize.find(object_id)
  end

  def params
    { formatted_object_id => object_id }
  end

  def channels
    singular_channel  = ['/', [object_class.downcase, object_id].join('_')].join
    plural_channel    = ['/', object_class.pluralize.downcase].join

    [singular_channel, plural_channel]
  end

  def uri
    URI.parse("http://#{ENV.fetch('CWF_FAYE_HOST')}/faye")
  end

  def formatted_object_id
    [object_class.downcase, 'id'].join('_')
  end
end
