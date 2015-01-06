class RemoteObjectFetcher

  class SparcApiError < StandardError
  end

  def initialize(resource, ids, query={})
    @resource = resource
    @ids      = ids
    @query    = query
  end

  def self.fetch(url)
    authorized_url = RemoteRequestBuilder.authorize_and_decorate!(url)

    RestClient.get(authorized_url, { accept: :json }) { |response, request, result, &block|
      raise SparcApiError unless response.code == 200

      @response = response
    }

    Yajl::Parser.parse @response
  end

  def build_and_fetch
    url = build_request

    RemoteObjectFetcher.fetch url
  end

  def build_request
    RemoteRequestBuilder.new(@resource, @ids, @query).build
  end
end
