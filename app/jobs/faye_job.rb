class FayeJob < ActiveJob::Base

  queue_as :faye

  def perform(object)
    FayeClient.new(data, channels(object)).publish
  end

  private

  def data
    'data'
  end

  def channels(object)
    object_class = object.class.to_s.downcase

    [
      ['/', [object_class, object.id].join('_')].join,
      ['/', object_class.pluralize].join
    ].flatten
  end
end
