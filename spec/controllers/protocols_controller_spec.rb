require 'rails_helper'

RSpec.describe ProtocolsController do

  describe "GET #index" do

    it "populates an array of protocols" do
      sign_in

      protocol = create(:protocol)
      get :index
      assigns(:arms).should eq([protocol])
    end 
  end
end