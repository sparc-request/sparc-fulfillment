class RemoteRequestBuilder

  DEFAULT_DEPTH = { depth: 'full' }.freeze

  def initialize(resource, ids, query={})
    @resource = resource
    @ids      = ids
    @query    = query
  end

  def self.authorize_and_decorate!(uri)
    url = Addressable::URI.parse uri

    url.user     = ENV.fetch('SPARC_API_USERNAME')
    url.password = ENV.fetch('SPARC_API_PASSWORD')

    if url.query_values.nil?
      url.query_values = DEFAULT_DEPTH
    elsif !url.query_values.keys.include?('depth')
      url.query_values.merge!(DEFAULT_DEPTH)
    end

    url.to_s
  end

  def build
    url = Addressable::URI.parse "#{scheme}://#{host}/#{segments}.json"

    if @query.any? || @ids.is_a?(Array)
      url.query_values = query_values
    end

    url.to_s
  end

  def build_and_authorize
    url = Addressable::URI.parse "#{scheme}://#{host}/#{segments}.json"

    url.user     = ENV.fetch('SPARC_API_USERNAME')
    url.password = ENV.fetch('SPARC_API_PASSWORD')

    if @query.any? || @ids.is_a?(Array)
      url.query_values = query_values
    end

    url.to_s
  end

  private

  def site
    [scheme, host].join
  end

  def scheme
    ENV.fetch('GLOBAL_SCHEME')
  end

  def host
    ENV.fetch('SPARC_API_HOST')
  end

  def version
    ENV.fetch('SPARC_API_VERSION')
  end

  def segments
    [
      version,
      @resource.pluralize.downcase,
      id
    ].compact.join('/')
  end

  def id
    if @ids.is_a?(Integer)
      @ids
    end
  end

  def query_values
    @query.merge!(normalized_ids)
  end

  def normalized_ids
    if @ids.is_a?(Integer)
      {}
    else
      { 'ids[]' => @ids }
    end
  end
end
