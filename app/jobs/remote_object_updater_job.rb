class RemoteObjectUpdaterJob < Struct.new(:object_id, :object_class, :callback_url)

  class SparcApiError < StandardError
  end

  def self.enqueue(object_id, object_class, callback_url)
    job = new(object_id, object_class.downcase, callback_url)

    Delayed::Job.enqueue job, queue: 'sparc_api_requests'
  end

  def perform
    update_local_object_from_remote_object
  end

  private

  def update_local_object_from_remote_object
    local_object.update_attributes normalized_attributes
  end

  def local_object
    object_class.classify.constantize.find object_id
  end

  def remote_object
    RemoteObjectFetcher.fetch(callback_url)
  end

  def normalized_attributes
    RemoteObjectNormalizer.new(object_class, remote_object[object_class]).normalize!
  end
end
