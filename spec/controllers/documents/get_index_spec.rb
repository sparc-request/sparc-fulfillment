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

  describe "GET #index" do

    context 'format: :js' do

      it "should get documents" do
        line_item = create(:line_item, protocol: create(:protocol), service: create(:service))
        document  = create(:document, documentable_id: line_item.id, documentable_type: 'LineItem')

        get :index, params: {
          document: {
            documentable_id: line_item.id,
            documentable_type: 'LineItem'
          }
        }, format: :js, xhr: true

        expect(assigns(:documents)).to eq([document])
      end
    end

    context 'format: :html' do

      it 'should render with :success' do
        get :index, format: :html

        expect(response).to be_success
      end
    end

    context 'format: :json' do

      before :each do
        identity = Identity.first
        @document = create(:document, documentable_type: 'Identity', documentable_id: identity.id)
      end

      it 'should render with :success' do
        get :index, format: :json

        expect(response).to be_success
      end

      it 'should assign documents' do
        get :index, format: :json

        expect(assigns(:documents)).to eq([@document])
      end
    end
  end
end
