require 'rails_helper'

RSpec.describe ReportsController, type: :controller do

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

      it 'does not assign @reports' do
        get :index, format: :html

        expect(assigns(:reports)).to_not be
      end
    end

    context 'content-type: application/json' do

      it 'renders the :index action' do
        get :index, format: :json

        expect(response).to be_success
      end

      it 'assigns @reports' do
        get :index, format: :json

        expect(assigns(:reports)).to be
      end
    end
  end
end
