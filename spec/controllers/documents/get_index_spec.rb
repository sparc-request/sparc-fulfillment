require 'rails_helper'

RSpec.describe DocumentsController, type: :controller do

  login_user

  describe "GET #index" do

    context 'format: :js' do

      it "should get documents" do
        line_item = create(:line_item, protocol: create(:protocol), service: create(:service))
        document  = create(:document, documentable_id: line_item.id, documentable_type: 'LineItem')

        xhr :get, :index, {
          document: {
            documentable_id: line_item.id,
            documentable_type: 'LineItem'
          },
          format: :js
        }

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
