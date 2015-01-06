require 'rails_helper'

RSpec.describe ProtocolsController do

  before :each do
    sign_in
  end

  describe "GET #index" do

    it "populates an array of protocols" do
      protocol = create(:protocol)
      get :index
      expect(assigns(:protocols)).to eq([protocol])
    end 
  end

  describe "GET #show" do

    it "assigns the requested protocol to @protocol" do
      protocol = create(:protocol, sparc_id: 1)
      get :show, id: protocol.sparc_id
      expect(assigns(:protocol)).to eq(protocol)
    end

    it "renders the #show view" do
      get :show, id: create(:protocol)
      expect(response).to render_template :show
    end
  end
end