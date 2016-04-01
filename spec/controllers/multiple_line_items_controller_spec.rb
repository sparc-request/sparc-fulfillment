require 'rails_helper'

RSpec.describe MultipleLineItemsController, type: :controller do

  # def create_and_assign_protocol_to_me
  #   identity              = Identity.first
  #   sub_service_request   = create(:sub_service_request_with_organization)
  #   protocol              = create(:protocol_imported_from_sparc, sub_service_request: sub_service_request)
  #   organization_provider = create(:organization_provider, name: "Provider")
  #   organization_program  = create(:organization_program, name: "Program", parent: organization_provider)
  #   organization          = sub_service_request.organization
  #   organization.update_attributes(parent: organization_program, name: "Core")
  #   FactoryGirl.create(:clinical_provider, identity: identity, organization: organization)
  #   FactoryGirl.create(:project_role_pi, identity: identity, protocol: protocol)

  #   protocol
  # end

  login_user

  describe "GET #new_line_items" do

    it "renders a template to add a service to multiple arms" do
      identity = create(:identity)
      sub_service_request   = create(:sub_service_request_with_organization)
      protocol              = create(:protocol_imported_from_sparc, sub_service_request: sub_service_request)
      organization_provider = create(:organization_provider, name: "Provider")
      organization_program  = create(:organization_program, name: "Program", parent: organization_provider)
      organization          = sub_service_request.organization
      organization.update_attributes(parent: organization_program, name: "Core")
      create(:clinical_provider, identity: identity, organization: organization)
      create(:project_role_pi, identity: identity, protocol: protocol)

      xhr :get, :new_line_items, {
        protocol_id: protocol.id,
        schedule_tab: "template",
        page_hash: ["1 1", "2 1", "3 2"],
        format: :js
      }

      expect(assigns(:protocol)).to eq(protocol)
      expect(assigns(:services)).to eq(protocol.organization.inclusive_child_services(:per_participant))
      expect(assigns(:page_hash)).to eq(["1 1", "2 1", "3 2"])
      expect(assigns(:schedule_tab)).to eq("template")
    end
  end

  describe "PUT #create_line_items" do
    it "handles the submission of the add line items form" do
      identity = create(:identity)
      sub_service_request   = create(:sub_service_request_with_organization)
      protocol              = create(:protocol_imported_from_sparc, sub_service_request: sub_service_request)
      organization_provider = create(:organization_provider, name: "Provider")
      organization_program  = create(:organization_program, name: "Program", parent: organization_provider)
      organization          = sub_service_request.organization
      organization.update_attributes(parent: organization_program, name: "Core")
      create(:clinical_provider, identity: identity, organization: organization)
      create(:project_role_pi, identity: identity, protocol: protocol)
      service = protocol.organization.services.first
      service.update_attribute(:one_time_fee, false)

      expect{
        post :create_line_items, {
          add_service_id: service.id,
          add_service_arm_ids_and_pages: ["#{protocol.arms.first.id} 1", "#{protocol.arms.second.id} 1"],
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
