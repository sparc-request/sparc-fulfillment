class RemoteObjectUpdaterJob < Struct.new(:object_id, :object_class, :callback_url)

  class SparcApiError < StandardError
  end

  def self.enqueue(object_id, object_class, callback_url)
    job = new(object_id, object_class.downcase, callback_url)

    Delayed::Job.enqueue job, queue: 'sparc_api_requests'
  end

  def perform
    qualified_url = qualify_url(callback_url)

    RestClient.get(qualified_url, params) { |response, request, result, &block|
      if response.code == 200
        parsed_json = parse_json(response)

        RemoteObjectUpdater.new(parsed_json, object).import!
      else
        raise SparcApiError
      end
    }
  end

  private

  def qualify_url(url)
    uri           = URI(url)
    uri.user      = ENV['SPARC_API_USERNAME']
    uri.password  = ENV['SPARC_API_PASSWORD']

    uri.to_s
  end

  def params
    { accept: :json }
  end

  def object
    @object ||= object_class.classify.constantize.find object_id
  end

  def parse_json(response)
    Yajl::Parser.parse response
  end
end
