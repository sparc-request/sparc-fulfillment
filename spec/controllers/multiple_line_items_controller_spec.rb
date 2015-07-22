require 'rails_helper'

RSpec.describe MultipleLineItemsController, type: :controller do

  login_user

  before do
    @protocol = create(:protocol_with_sub_service_request)
    @service  = @protocol.organization.services.first
  end

  describe "GET #new" do

    it "renders a template to add a service to multiple arms" do
      xhr :get, :new_line_items, {
        protocol_id: @protocol.id,
        service_id: @service.id,
        format: :js
      }
      expect(assigns(:protocol)).to eq(@protocol)
      expect(assigns(:selected_service)).to eq(@service.id)
      expect(assigns(:services).map(&:id).sort).to eq(@protocol.organization.inclusive_child_services(:per_participant).map(&:id).sort)
      expect(assigns(:arm_ids).map(&:id).sort).to eq(@protocol.arms.map(&:id).sort)
    end
  end

  describe "GET #edit" do

    it "renders a template to remove a service from multiple arms" do
      xhr :get, :new_line_items, {
        protocol_id: @protocol.id,
        service_id: @service.id,
        format: :js
      }
      expect(assigns(:protocol)).to eq(@protocol)
      expect(assigns(:selected_service)).to eq(@service.id)
      expect(assigns(:services).map(&:id).sort).to eq(@protocol.organization.inclusive_child_services(:per_participant).map(&:id).sort)
      expect(assigns(:arm_ids).map(&:id).sort).to eq((@protocol.arms.map{ |arm| arm.id if arm.line_items.detect{|li| li.service_id.to_s == @selected_service} }).map(&:id).sort)
    end
  end

  describe "PUT #update" do

    it "should create multiple line items" do
      arm1 = create(:arm, protocol: @protocol)
      arm2 = create(:arm, protocol: @protocol)
      put :update_line_items, {
        header_text: "Add",
        arm_ids: [arm1.id.to_s, arm2.id.to_s],
        service_id: @service.id,
        format: :js
      }
      arm1.reload
      arm2.reload
      expect(arm1.line_items.count).to eq(1)
      expect(arm1.line_items.first.service_id).to eq(@service.id)
      expect(arm2.line_items.count).to eq(1)
      expect(arm2.line_items.first.service_id).to eq(@service.id)
    end

    it "should remove multiple line items" do
      arm1 = create(:arm, protocol: @protocol)
      arm2 = create(:arm, protocol: @protocol)
      line_item1 = create(:line_item, arm_id: arm1.id, service_id: @service.id, protocol: @protocol)
      line_item2 = create(:line_item, arm_id: arm2.id, service_id: @service.id, protocol: @protocol)
      arm1.reload
      arm2.reload
      put :update_line_items, {
        header_text: "Remove",
        arm_ids: [arm1.id.to_s, arm2.id.to_s],
        service_id: @service.id,
        format: :js
      }
      arm1.reload
      arm2.reload
      expect(arm1.line_items.count).to eq(0)
      expect(arm2.line_items.count).to eq(0)
    end

  end

end
