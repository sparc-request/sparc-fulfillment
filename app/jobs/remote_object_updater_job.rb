class RemoteObjectUpdaterJob < Struct.new(:object_id, :object_class)

  class SparcApiError < StandardError
  end

  def self.enqueue(object_id, object_class)
    job = new(object_id, object_class.downcase)

    Delayed::Job.enqueue job, queue: 'sparc_api_requests'
  end

  def perform
    RestClient.get(url, params) { |response, request, result, &block|
      raise SparcApiError unless response.code == 200

      RemoteObjectUpdater.new(response, object).import!
    }
  end

  private

  def params
    { accept: :json }
  end

  def url
    [
      http_protocol,
      '://',
      ENV['SPARC_API_USERNAME'],
      ':',
      ENV['SPARC_API_PASSWORD'],
      '@',
      [
        ENV['SPARC_API_HOST'],
        sparc_api_version,
        object_class.downcase.pluralize,
        object.sparc_id
      ].join('/'),
      '.json'
    ].flatten.join
  end

  def http_protocol
    'http'
  end

  def sparc_api_version
    'v1'
  end

  def object
    @object ||= object_class.classify.constantize.find object_id
  end
end
