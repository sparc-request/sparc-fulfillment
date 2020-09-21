# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

class RemoteObjectFetcher

  class SparcApiError < StandardError
  end

  def initialize(resource, ids, query={})
    @resource = resource
    @ids      = ids
    @query    = query
  end

  def self.fetch(url)
    token     = authorize()
    full_url  = RemoteRequestBuilder.decorate(url)

    RestClient::Resource.new(full_url, { access_token: token }).get({ accept: :json }) do |response, request, result, &block|
      raise SparcApiError unless response.code == 200

      @response = Yajl::Parser.parse response
    end

    @response
  end

  def build_and_fetch
    url = build_request()
    RemoteObjectFetcher.fetch(url)
  end

  private

  def self.authorize
    url = RemoteRequestBuilder.token_url

    RestClient.post(url, { client_id: ENV.fetch('SPARC_API_CLIENT_ID'), client_secret: ENV.fetch('SPARC_API_CLIENT_SECRET') }) do |response, request, result, &block|
      raise SparcApiError unless response.code == 200

      @token = Yajl::Parser.parse(response)['access_token']
    end

    @token
  end

  def build_request
    RemoteRequestBuilder.new(@resource, @ids, @query).build
  end
end
