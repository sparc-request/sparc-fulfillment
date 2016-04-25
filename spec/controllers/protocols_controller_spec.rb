require 'rails_helper'

RSpec.describe ProtocolsController, type: :controller do

  before :each do
    sign_in
  end

  describe "GET #index" do

    context 'content-type: text/html' do

      it 'renders the :index action' do
        get :index, format: :html

        expect(response).to be_success
        expect(response).to render_template :index
      end

      it 'does not assign @protocols' do
        get :index, format: :html

        expect(assigns(:protocols)).to_not be
      end
    end

    context 'content-type: application/json' do

      it 'renders the :index action' do
        get :index, format: :json

        expect(response).to be_success
      end

      it 'assigns @protocols' do
        get :index, format: :json

        expect(assigns(:protocols)).to be
      end
    end
  end

  describe "GET #show" do

    it "returns http success" do
      identity              = Identity.first
      organization          = create(:organization)
      sub_service_request   = create(:sub_service_request, organization_id: organization.id)
      protocol              = create(:protocol, sub_service_request: sub_service_request)
      create(:clinical_provider, identity: identity, organization: organization)
      create(:project_role_pi, identity: identity, protocol: protocol)

      xhr :get, :show, id: protocol.id

      expect(assigns(:protocol)).to eq(protocol)
    end

    it "assigns the requested protocol to @protocol" do
      protocol = create_and_assign_protocol_to_me
      get :show, id: protocol.id

      expect(assigns(:protocol)).to eq(protocol)
    end

    it "renders the #show view" do
      identity              = Identity.first
      sign_in identity
      organization          = create(:organization)
      sub_service_request   = create(:sub_service_request, organization_id: organization.id)
      protocol              = create(:protocol, sub_service_request: sub_service_request)
      create(:clinical_provider, identity: identity, organization: organization)
      create(:project_role_pi, identity: identity, protocol: protocol)

      xhr :get, :show, id: protocol.id, format: :js

      expect(response).to render_template :show
    end
  end
end
