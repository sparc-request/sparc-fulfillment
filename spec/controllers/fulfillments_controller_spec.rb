require 'rails_helper'

RSpec.describe FulfillmentsController do

  before :each do
    sign_in
    @line_item = create(:line_item, protocol: create(:protocol_imported_from_sparc), service: create(:service))
    @fulfillment = create(:fulfillment, line_item: @line_item)
  end

  describe "GET #index" do

    context 'content-type: application/json' do

      it 'renders the :index action' do
        xhr :get, :index, line_item_id: @line_item.id, format: :js

        expect(response).to be_success
      end

      it 'assigns @line_item' do
        xhr :get, :index, line_item_id: @line_item.id, format: :js

        expect(assigns(:line_item)).to be
      end
    end

    context 'content-type: application/js' do

      it 'assigns @fulfillments' do
        get :index, line_item_id: @line_item.id, format: :json

        expect(assigns(:fulfillments)).to be
      end
    end
  end

  describe "GET #new" do
    it "should instantiate a new Fulfillment" do
      xhr :get, :new, {
        line_item_id: @line_item.id,
        format: :js
      }
      expect(assigns(:fulfillment)).to be_a_new(Fulfillment)
    end
  end

  describe "POST #create" do
    it "should create a new fulfillment" do
      attributes = @fulfillment.attributes
      attributes.delete_if{ |key| ["fulfilled_at", "created_at", "updated_at"].include?(key) }
      attributes[:fulfilled_at] = "09-10-2015"
      attributes[:components] = @line_item.components.map{ |c| c.id.to_s }
      expect{
        post :create, {
          fulfillment: attributes,
          format: :js
        }
      }.to change(Fulfillment, :count).by(1)
    end
  end

  describe "GET #edit" do
    it "should select an instantiated fulfillment" do
      xhr :get, :edit, {
        id: @fulfillment.id,
        format: :js
      }
      expect(assigns(:fulfillment)).to eq(@fulfillment)
    end
  end

  describe "PUT #update" do
    it "should update a fulfillment" do
      put :update, {
        id: @fulfillment.id,
        fulfillment: attributes_for(:fulfillment, line_item_id: @line_item.id, quantity: 328),
        format: :js
      }
      @fulfillment.reload
      expect(@fulfillment.quantity).to eq 328
    end
  end

end
