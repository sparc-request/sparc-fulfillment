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

require 'rails_helper'

RSpec.describe RemoteObjectFetcher do

  describe '#self.fetch(url)' do
    it 'should authorize the request and fetch the requested URL' do
      protocol  = create(:sparc_protocol)
      url       = "#{ENV.fetch('GLOBAL_SCHEME')}://#{ENV.fetch('SPARC_API_HOST')}/api/#{ENV.fetch('SPARC_API_VERSION')}/protocols/#{protocol.id}.json?depth=full"

      stub_request(:get, url).to_return(status: 200, body: protocol.to_json)

      expect(RemoteObjectFetcher).to receive(:authorize).and_return('some_token')
      expect(RemoteObjectFetcher.fetch(url)).to eq(Yajl::Parser.parse protocol.to_json)
    end
  end

  describe '#build_and_fetch' do
    it 'should build a URL and fetch the requested resource(s)' do
      protocol  = create(:sparc_protocol)
      url       = "#{ENV.fetch('GLOBAL_SCHEME')}://#{ENV.fetch('SPARC_API_HOST')}/api/#{ENV.fetch('SPARC_API_VERSION')}/protocols/#{protocol.id}.json?depth=full"

      stub_request(:get, url).to_return(status: 200, body: protocol.to_json)

      expect(RemoteObjectFetcher).to receive(:authorize).and_return('some_token')
      expect(RemoteObjectFetcher.new('protocols', protocol.id, {}).build_and_fetch).to eq(Yajl::Parser.parse protocol.to_json)
    end
  end
end
