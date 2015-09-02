require 'rails_helper'

RSpec.describe VisitGroupsController, type: :controller do

  login_user

  before :each do
    @protocol = create_and_assign_protocol_to_me
    @arm = @protocol.arms.first
    @line_item = @arm.line_items.first
    @visit_group = @line_item.visit_groups.first
  end

  describe "GET #new" do
    it "should assign the proper vars without an arm_id" do
      xhr :get, :new, {
        protocol_id: @protocol.id,
        schedule_tab: "template",
        current_page: "1",
        format: :js
      }
      expect(assigns(:protocol)).to eq(@protocol)
      expect(assigns(:current_page)).to eq("1")
      expect(assigns(:visit_group)).to be_a_new(VisitGroup)
      expect(assigns(:schedule_tab)).to eq("template")
      expect(assigns(:arm)).to eq(@protocol.arms.first)
    end

    it "should assign the proper vars with an arm_id" do
      xhr :get, :new, {
        protocol_id: @protocol.id,
        schedule_tab: "template",
        current_page: "1",
        arm_id: @arm.id,
        format: :js
      }
      expect(assigns(:protocol)).to eq(@protocol)
      expect(assigns(:current_page)).to eq("1")
      expect(assigns(:visit_group)).to be_a_new(VisitGroup)
      expect(assigns(:schedule_tab)).to eq("template")
      expect(assigns(:arm)).to eq(@arm)
    end
  end

  describe "POST #create" do
    it "should create a new visit_group" do
      expect{
        post :create, {
          protocol_id: @protocol.id,
          arm_id: @arm.id,
          visit_group: attributes_for(:visit_group, arm_id: @arm.id),
          format: :js
        }
      }.to change(VisitGroup, :count).by(1)
    end
  end

  describe "POST #update" do
    it "should update an existing visit_group" do
      post :update, {
        id: @visit_group.id,
        visit_group: @visit_group.attributes.merge({"name" => "BABOOM~*"}),
        format: :js
      }
      expect(assigns(:visit_group)).to have_attributes(name: "BABOOM~*")
    end
  end

  describe "POST #destroy" do
    it "should destroy an exisiting visit_group" do
      expect{
        post :destroy, {
          id: @visit_group.id,
          page: "1",
          schedule_tab: "template",
          format: :js
        }
      }.to change(VisitGroup, :count).by(-1)
    end

    it "should create an error when there is only one visit_group on the arm" do
      @arm.update_attributes(visit_count: 1)
      post :destroy, {
        id: @visit_group.id,
        page: "1",
        schedule_tab: "template",
        format: :js
      }
      expect(assigns(:visit_group).errors.messages).to eq(arm: ["must have at least one visit. Add another visit before deleting this one"])
    end

    it "should create an error when the visit_group has completed procedures under it" do
      create(:procedure_complete, appointment: @visit_group.appointments.first, arm: @arm, completed_date: "10-09-2010")
      delete :destroy, {
        id: @visit_group.id,
        page: "1",
        schedule_tab: "template",
        format: :js
      }
      expect(assigns(:visit_group).errors.messages).to eq(visit_group: ["'#{@visit_group.name}' has completed procedures and cannot be deleted"])
    end
  end

  describe "GET #navigate_to_visit_group" do
    it "should assign the appropriate vars when there is a visit group id" do
      xhr :get, :navigate_to_visit_group, {
        protocol_id: @protocol.id,
        visit_group_id: @visit_group.id,
        arm_id: @arm.id,
        intended_action: "edit",
        format: :js
      }
      expect(assigns(:protocol)).to eq(@protocol)
      expect(assigns(:intended_action)).to eq("edit")
      expect(assigns(:visit_group)).to eq(@visit_group)
      expect(assigns(:arm)).to eq(@visit_group.arm)
    end

    it "should assign the appropriate vars when there is only an arm id" do
      xhr :get, :navigate_to_visit_group, {
        protocol_id: @protocol.id,
        arm_id: @arm.id,
        intended_action: "edit",
        format: :js
      }
      expect(assigns(:protocol)).to eq(@protocol)
      expect(assigns(:intended_action)).to eq("edit")
      expect(assigns(:visit_group)).to eq(@arm.visit_groups.first)
      expect(assigns(:arm)).to eq(@arm)
    end

    it "should assign the appropriate vars without arm_id or visit_group_id" do
      xhr :get, :navigate_to_visit_group, {
        protocol_id: @protocol.id,
        intended_action: "edit",
        format: :js
      }
      expect(assigns(:protocol)).to eq(@protocol)
      expect(assigns(:intended_action)).to eq("edit")
      expect(assigns(:visit_group)).to eq(@protocol.arms.first.visit_groups.first)
      expect(assigns(:arm)).to eq(@protocol.arms.first)
    end
  end
end

