class SparcApiUrlBuilder

  def initialize(resource, id=nil, query_values=nil)
    @resource     = resource
    @id           = id
    @query_values = query_values
  end

  def to_s
    uri.to_s
  end

  private

  def uri
    uri               = Addressable::URI.parse site
    uri.user          = username
    uri.password      = password
    uri.path          = path
    uri.query_values  = @query_values

    uri
  end

  def username
    ENV.fetch('SPARC_API_USERNAME')
  end

  def password
    ENV.fetch('SPARC_API_PASSWORD')
  end

  def path
    [
      [
        version,
        @resource.pluralize.downcase,
        @id
      ].compact.join('/'),
      '.json'
    ].flatten.join
  end

  def site
    [scheme, host].join
  end

  def scheme
    [ENV.fetch('SPARC_API_SCHEME'), '//'].join(':')
  end

  def host
    ENV.fetch('SPARC_API_HOST')
  end

  def version
    ENV.fetch('SPARC_API_VERSION')
  end
end

# Examples:

# SparcApiUrlBuilder.new('service', 1).to_s
#   "https://username:pasword@sparc.musc.edu/v1/services/1.json"

# SparcApiUrlBuilder.new('service', 1, { depth: 'full_with_shallow_reflections' }).to_s
#   "https://username:pasword@sparc.musc.edu/v1/services/1.json?depth=full_with_shallow_reflections"
