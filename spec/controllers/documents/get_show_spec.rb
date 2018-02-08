# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

  render_views

  login_user

  describe 'GET #show' do

    context 'Document is accessible by Identity' do

      it 'should render the document' do
        protocol  = create(:protocol)
        service   = create(:service)
        line_item = create(:line_item, protocol: protocol, service: service)
        document  = create(:document_with_csv_file,
                            documentable_id: line_item.id,
                            documentable_type: 'LineItem')

        get :show, params: { id: document.id }

        expect(response.headers["Content-Type"]).to include("text/csv")
        expect(response.body).to eq("a, b, c")
      end
    end

    context 'Document is not accessible by Identity' do

      it 'should not render the document' do
        identity  = create(:identity)
        document  = create(:document_with_csv_file,
                            documentable_id: identity.id,
                            documentable_type: 'Identity')

        get :show, params: { id: document.id }

        expect(response.body).to eq("")
      end
    end
  end
end
