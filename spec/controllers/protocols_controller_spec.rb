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

    before :each do
      create_and_assign_protocol_to_me
      @protocol = Protocol.first
    end

    it "returns http success" do
      get :show, id: @protocol.sparc_id

      expect(response).to be_success
    end

    it "assigns the requested protocol to @protocol" do
      get :show, id: @protocol.sparc_id

      expect(assigns(:protocol)).to eq(@protocol)
    end

    it "renders the #show view" do
      get :show, id: @protocol.sparc_id

      expect(response).to render_template :show
    end
  end
end
