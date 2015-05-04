class RemoteServiceUpdaterJob < SparcRequestJob

  def perform(*args)
    @service            = args.first
    @counter_direction  = args.last

    RestClient.put(url, payload, content_type: "application/json") { |response, request, result, &block|
      raise SparcApiError unless response.code == 200

      @response = response
    }
  end

  private

  def url
    RemoteRequestBuilder.new("service", @service.id).build_and_authorize
  end

  def payload
    {
      service: {
        line_items_count: @counter_direction
      }
    }.to_json
  end
end
