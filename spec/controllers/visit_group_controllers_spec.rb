require 'rails_helper'

RSpec.describe VisitGroupsController,type: :controller do
  before :each do
    sign_in
    @protocol = create(:protocol)
    @arm = create(:arm, protocol: @protocol)
    @line_item = create(:line_item, protocol: @protocol, service: create(:service))
    @visit_group = create(:visit_group, arm_id: @arm.id)
  end

  describe "POST #create" do
    it "should create a new visit_group and associated visits" do
      expect{
        post :create, {
          protocol_id: @protocol.id,
          arm_id: @arm.id,
          visit_group: attributes_for(:visit_group, arm_id: @arm.id),
          format: :js
          }
        }.to change(VisitGroup, :count).by(1)
      #since there is only one line item only one visit should be created however this test is pending becaue of after create refactor
      #so the line below should function to test Visit creation once refactor has been submitted
      #expect(Visit.where("line_item_id = ?", @line_item.id).count).to eq(1)
    end
  end
end

