# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

RSpec.describe DocumentsController, type: :controller do

  login_user

  describe 'POST #create' do

    context 'success' do

      before do
        identity  = Identity.first
        document  = Rack::Test::UploadedFile.new(File.join('db', 'fixtures', 'test_document.txt'),'txt/plain')
        params    = { document: { title: 'test_document', documentable_id: identity.id, documentable_type: 'Identity', document: document } }

        post :create, params: params, format: :js, xhr: true
      end

      it 'should render with status: :success' do
        expect(response).to be_success
      end

      it 'should persist a Document object to database' do
        expect(assigns(:document)).to be_persisted
      end

      it 'should persist a file to the filesystem' do
        expect(File.exists?(assigns(:document).path)).to be
      end
    end

    context 'failure' do

      it 'should assign an error message to @error' do
        identity  = Identity.first
        params    = { document: { documentable_id: identity.id, documentable_type: 'Identity', document: nil } }

        post :create, params: params, format: :js, xhr: true

        expect(assigns(:error)).to be
      end
    end
  end
end
