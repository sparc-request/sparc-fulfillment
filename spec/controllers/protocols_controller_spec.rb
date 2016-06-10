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
