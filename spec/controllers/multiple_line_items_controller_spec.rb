require 'rails_helper'

RSpec.describe MultipleLineItemsController, type: :controller do

  login_user

  before :each do
    identity              = create(:identity)
    organization          = create(:organization)
    sub_service_request   = create(:sub_service_request, organization_id: organization.id)
    @service              = create(:service, organization_id: organization.id, one_time_fee: false)
    @protocol             = create(:protocol_imported_from_sparc, sub_service_request: sub_service_request)
    organization_provider = create(:organization_provider, name: "Provider")
    organization_program  = create(:organization_program, name: "Program", parent: organization_provider)
    organization.update_attributes(parent: organization_program, name: "Core")
    create(:clinical_provider, identity: identity, organization: organization)
    create(:project_role_pi, identity: identity, protocol: @protocol)
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

    it "requires arms to be selected" do
      expect{
        post :create_line_items, {
          add_service_id: @service.id,
          schedule_tag: "template",
          format: :js
        }
      }.to_not change(LineItem, :count)
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

    it "requires arms to be selected" do
      create(:line_item, service: @service, arm: @protocol.arms.first, protocol: @protocol)

      expect{
        post :destroy_line_items, {
          remove_service_id: @service.id,
          format: :js
        }
      }.to_not change(LineItem, :count)
    end

    it "should not delete services with completed procedures" do
      participant = create(:participant_with_appointments, protocol: @protocol, arm: @protocol.arms.first)
                    create(:procedure_complete, service: @service, appointment: participant.appointments.first, arm: @protocol.arms.first)
                    create(:line_item, service: @service, arm: @protocol.arms.first, protocol: @protocol)

      expect{
        post :destroy_line_items, {
          remove_service_id: @service.id,
          remove_service_arm_ids: ["#{@protocol.arms.first.id}"],
          format: :js
        }
      }.to_not change(LineItem, :count)
    end
  end
end
