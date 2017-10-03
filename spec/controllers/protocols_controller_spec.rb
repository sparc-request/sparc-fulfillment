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

RSpec.describe ProtocolsController, type: :controller do

  login_user

  describe "GET #index" do

    context 'content-type: text/html' do
      before :each do
        get :index, format: :html
      end

      it { is_expected.to render_template :index }
      it { is_expected.to respond_with :ok }
    end

    context 'content-type: application/json' do
      before :each do
        get :index, format: :json
      end

      it 'assigns @protocols' do
        expect(assigns(:protocols)).to be
      end

      it { is_expected.to render_template :index }
      it { is_expected.to respond_with :ok }
    end
  end

  describe "GET #show" do
    before :each do
      identity            = subject.current_identity
      organization        = create(:organization, process_ssrs: true)
      sub_service_request = create(:sub_service_request, organization: organization)
      @protocol           = create(:protocol, sub_service_request: sub_service_request)
                            create(:clinical_provider, identity: identity, organization: organization)
                            create(:project_role_pi, identity: identity, protocol: @protocol)

      get :show, id: @protocol.id
    end

    it "assigns the requested protocol to @protocol" do
      expect(assigns(:protocol)).to eq(@protocol)
    end

    it { is_expected.to render_template :show }
    it { is_expected.to respond_with :ok }
  end
end
