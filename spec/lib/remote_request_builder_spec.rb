# Copyright © 2011-2017 MUSC Foundation for Research Development~
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

RSpec.describe RemoteRequestBuilder do

  describe '#authorize_and_decorate!' do

    it 'should add HTTP basic auth and the default :depth to the url' do
      original_url = "http://#{ENV.fetch('SPARC_API_HOST')}/#{ENV.fetch('SPARC_API_VERSION')}/services/1.json"
      expected_url = "http://#{ENV.fetch('SPARC_API_USERNAME')}:#{ENV.fetch('SPARC_API_PASSWORD')}@#{ENV.fetch('SPARC_API_HOST')}/#{ENV.fetch('SPARC_API_VERSION')}/services/1.json?depth=full"

      expect(RemoteRequestBuilder.authorize_and_decorate!(original_url)).to eq(expected_url)
    end
  end

  describe '#build' do

    context 'single resource' do

      it 'should return a valid URL' do
        expected_url = "http://#{ENV.fetch('SPARC_API_HOST')}/#{ENV.fetch('SPARC_API_VERSION')}/services/1.json"

        expect(RemoteRequestBuilder.new('service', 1).build).to eq(expected_url)
      end
    end

    context 'multiple resources' do

      context 'with params[:ids]' do

        it 'should return a valid URL' do
          expected_url = "http://#{ENV.fetch('SPARC_API_HOST')}/#{ENV.fetch('SPARC_API_VERSION')}/services.json?ids%5B%5D=1&ids%5B%5D=2&ids%5B%5D=3"

          expect(RemoteRequestBuilder.new('service', [1, 2, 3]).build).to eq(expected_url)
        end
      end

      context 'with params[:depth]' do

        it 'should return a valid URL' do
          expected_url = "http://#{ENV.fetch('SPARC_API_HOST')}/#{ENV.fetch('SPARC_API_VERSION')}/services/1.json?depth=full_with_shallow_reflections"

          expect(RemoteRequestBuilder.new('service', 1, { depth: 'full_with_shallow_reflections' }).build).to eq(expected_url)
        end
      end

      context 'with params[:depth] and params[:ids]' do

        it 'should return a valid URL' do
          expected_url = "http://#{ENV.fetch('SPARC_API_HOST')}/#{ENV.fetch('SPARC_API_VERSION')}/services.json?depth=full_with_shallow_reflections&ids%5B%5D=1&ids%5B%5D=2&ids%5B%5D=3"

          expect(RemoteRequestBuilder.new('service', [1, 2, 3], { depth: 'full_with_shallow_reflections' }).build).to eq(expected_url)
        end
      end
    end
  end
end
