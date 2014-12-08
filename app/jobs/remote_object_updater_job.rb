class RemoteObjectUpdaterJob < Struct.new(:object_id, :object_class, :callback_url)

  class SparcApiError < StandardError
  end

  def self.enqueue(object_id, object_class, callback_url)
    job = new(object_id, object_class.downcase, callback_url)

    Delayed::Job.enqueue job, queue: 'sparc_api_requests'
  end

  def perform
    RestClient.get(callback_url, params) { |response, request, result, &block|
      raise SparcApiError unless response.code == 200

      RemoteObjectUpdater.new(response, object).import!
    }
  end

  private

  def params
    { accept: :json }
  end

  def object
    @object ||= object_class.classify.constantize.find object_id
  end
end
