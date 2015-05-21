require 'rails_helper'

RSpec.describe LineItemsController do

  before :each do
    sign_in
    @protocol = create(:protocol)
    @service = create(:service)
    @line_item = create(:line_item, protocol: @protocol, service: @service)
  end

  describe "GET #new" do
    it "should instantiate a new LineItem" do
      xhr :get, :new, {
        protocol_id: @protocol.id,
        format: :js
      }
      expect(assigns(:line_item)).to be_a_new(LineItem)
    end
  end

  describe "POST #create" do
    it "should create a new LineItem" do
      attributes = @line_item.attributes
      attributes.delete_if{ |key| ["created_at", "updated_at"].include?(key) }
      attributes[:quantity_requested] = "75"
      expect{
        post :create, {
          line_item: attributes,
          format: :js
        }
      }.to change(LineItem, :count).by(1)
    end
  end

  describe "GET #edit" do
    it "should select an instantiated LineItem" do
      xhr :get, :edit, {
        id: @line_item.id,
        format: :js
      }
      expect(assigns(:line_item)).to eq(@line_item)
    end
  end

  describe "PUT #update" do
    it "should update a LineItem" do
      put :update, {
        id: @line_item.id,
        line_item: attributes_for(:line_item, protocol_id: @protocol.id, service_id: @service.id, quantity_requested: 328),
        format: :js
      }
      @line_item.reload
      expect(@line_item.quantity_requested).to eq 328
    end
  end

end
