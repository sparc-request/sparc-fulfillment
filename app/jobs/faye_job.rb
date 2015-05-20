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
    if object_class.downcase == "protocol"
      singular_channel  = ['/', [object_class.downcase, object_id].join('_')].join
      plural_channel    = ['/', object_class.pluralize.downcase].join

      [singular_channel, plural_channel]

    elsif object_class.downcase == "report"
      plural_channel = ['/', object_class.pluralize.downcase].join
      [plural_channel]
    end
  end

  def uri
    URI.parse("#{ENV.fetch('GLOBAL_SCHEME')}://#{ENV.fetch('CWF_FAYE_HOST')}/faye")
  end

  def formatted_object_id
    [object_class.downcase, 'id'].join('_')
  end
end
