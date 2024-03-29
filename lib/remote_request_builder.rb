# Copyright © 2011-2023 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

class RemoteRequestBuilder

  DEFAULT_DEPTH = { depth: 'full' }.freeze

  def initialize(resource, ids, query={})
    @resource = resource
    @ids      = ids
    @query    = query
  end

  def self.token_url
    "#{scheme}://#{host}/api/token.json"
  end

  def self.decorate(uri)
    url = Addressable::URI.parse uri

    if url.query_values.nil?
      url.query_values = DEFAULT_DEPTH
    elsif !url.query_values.keys.include?('depth')
      url.query_values.merge!(DEFAULT_DEPTH)
    end

    url.to_s
  end

  def build(type=nil)
    url = Addressable::URI.parse "#{scheme}://#{host}/api/#{segments}.json"
    url.query_values = query_values if @query.any? || @ids.is_a?(Array)
    url.to_s
  end

  private

  def self.site
    [scheme, host].join
  end

  def self.scheme
    ENV.fetch('GLOBAL_SCHEME')
  end

  def self.host
    ENV.fetch('SPARC_API_HOST')
  end

  def self.version
    ENV.fetch('SPARC_API_VERSION')
  end

  def site
    self.class.site
  end

  def scheme
    self.class.scheme
  end

  def host
    self.class.host
  end

  def version
    self.class.version
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
