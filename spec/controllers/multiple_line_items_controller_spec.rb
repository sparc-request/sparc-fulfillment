require 'rails_helper'

RSpec.describe MultipleLineItemsController, type: :controller do

  login_user

  before do
    @protocol = create_and_assign_protocol_to_me
    @service  = @protocol.organization.services.first
  end

  describe "GET #new_line_items" do

    it "renders a template to add a service to multiple arms" do
      xhr :get, :new_line_items, {
        protocol_id: @protocol.id,
        schedule_tab: "template",
        page_hash: ["1 1", "2 1", "3 2"],
        format: :js
      }
      expect(assigns(:protocol)).to eq(@protocol)
      expect(assigns(:services)).to eq(@protocol.organization.inclusive_child_services(:per_participant))
      expect(assigns(:page_hash)).to eq(["1 1", "2 1", "3 2"])
      expect(assigns(:schedule_tab)).to eq("template")
    end
  end

  describe "PUT #create_line_items" do
    it "handles the submission of the add line items form" do
      expect{
        post :create_line_items, {
          add_service_id: @service.id,
          add_service_arm_ids_and_pages: ["#{@protocol.arms.first.id} 1", "#{@protocol.arms.second.id} 1"],
          schedule_tab: "template",
          format: :js
        }
      }.to change(LineItem, :count).by(2)
    end
  end

  describe "GET #edit_line_items" do

    it "renders a template to remove a service from multiple arms" do
      xhr :get, :edit_line_items, {
        protocol_id: @protocol.id,
        service_id: @service.id,
        format: :js
      }
      expect(assigns(:protocol)).to eq(@protocol)
      expect(assigns(:all_services)).to eq(@protocol.line_items.map(&:service).uniq)
      expect(assigns(:service)).to eq(@service)
      expect(assigns(:arms)).to eq((@protocol.arms.select{ |arm| arm.line_items.detect{|li| li.service_id == @service.id} }))
    end
  end

  describe "PUT #destroy_line_items" do
    it "handles the submission of the remove line items form" do
      create(:line_item, service: @service, arm: @protocol.arms.first, protocol: @protocol)
      create(:line_item, service: @service, arm: @protocol.arms.second, protocol: @protocol)
      expect{
        post :destroy_line_items, {
          remove_service_id: @service.id,
          remove_service_arm_ids: ["#{@protocol.arms.first.id}", "#{@protocol.arms.second.id}"],
          format: :js
        }
      }.to change(LineItem, :count).by(-2)
    end
  end
end
