require 'rails_helper'

RSpec.describe ServiceCalendarController do
  before :each do
    sign_in
    @protocol = create(:protocol)
    @arm = create(:arm_imported_from_sparc, protocol_id: @protocol.id, visit_count: 10)
  end

  describe "GET #change_page" do
    it "should change the page to the page passed in" do
      tab = 'template'
      page = 1
      xhr :get, :change_page, {
        page: page + 1,
        arm_id: @arm.id,
        tab: tab,
        format: :js
      }
      expect(assigns(:page)).to eq(page + 1)
    end

  end

  describe "GET #change_tab" do
    it "should change the tab to the tab passed in" do
      page = 1
      xhr :get, :change_tab, {
        arms_and_pages: {"#{@arm.id}" => page},
        tab: 'quantity',
        format: :js
      }
      expect(assigns(:tab)).to eq('quantity')
    end
  end

  describe "PUT #check_visit" do
    it "should set the visits research quantity to 1, insurance and effort to 0 when checked true is passed in" do
      visit = Visit.first
      visit.update_attributes(research_billing_qty: 0, insurance_billing_qty: 0, effort_billing_qty: 0)
      put :check_visit, {
        visit_id: visit.id,
        checked: 'true',
        format: :js
      }
      expect(assigns(:visit).research_billing_qty).to eq(1)
    end

    it "should set the visits research quantity to 0, insurance and effort to 0 when checked false is passed in" do
      visit = Visit.first
      visit.update_attributes(research_billing_qty: rand(1..10), insurance_billing_qty: rand(1..10), effort_billing_qty: rand(1..10))
      put :check_visit, {
        visit_id: visit.id,
        checked: 'false',
        format: :js
      }
      expect(assigns(:visit).research_billing_qty).to eq(0)
      expect(assigns(:visit).insurance_billing_qty).to eq(0)
      expect(assigns(:visit).effort_billing_qty).to eq(0)
    end
  end

  describe "PUT #change_quantity" do
    it "should change the visits research quantity to the quantity passed in" do
      qty = rand(1..15)
      visit = Visit.first
      put :change_quantity, {
        visit_id: visit.id,
        qty_type: 'research_billing_qty',
        quantity: qty,
        format: :js
      }
      expect(assigns(:visit).research_billing_qty).to eq(qty)
    end

    it "should change the visits insurance quantity to the quantity passed in" do
      qty = rand(1..15)
      visit = Visit.first
      put :change_quantity, {
        visit_id: visit.id,
        qty_type: 'insurance_billing_qty',
        quantity: qty,
        format: :js
      }
      expect(assigns(:visit).insurance_billing_qty).to eq(qty)
    end
  end

  describe "PUT #change_visit_name" do
    it "should change the visit groups name to the name passed in" do
      visit_group = VisitGroup.first
      name = 'Test name change'
      put :change_visit_name, {
        visit_group_id: visit_group.id,
        name: name,
        format: :js
      }
      expect(assigns(:visit_group).name).to eq(name)
    end
  end

  describe "GET #edit_service" do
    it "should retrieve the correct line_item" do
      line_item = LineItem.first
      xhr :get, :edit_service, {
        line_item_id: line_item.id,
        format: :js
      }
      expect(assigns(:line_item)).to eq(line_item)
    end
  end

  describe "PATCH #update_service" do
    it "should change the service id of the line item" do
      line_item = LineItem.first
      service = create(:service)
      put :update_service, {
        line_item: {id: line_item.id, service_id: service.id},
        format: :js
      }
      expect(assigns(:line_item).service_id).to eq(service.id)
    end
  end

  describe "PUT #check_row" do
    it "should set all visits for the line_item to have a research_billing_qty of 1 when checked" do
      line_item = LineItem.where(arm: @arm).first
      put :check_row, {
        line_item_id: line_item.id,
        check: 'true',
        format: :js
      }
      visit_count = Visit.where(line_item_id: line_item.id).where(research_billing_qty: 1).count
      expect(visit_count).to eq(@arm.visit_count)
    end

    it "should set all visits for the line_item to have a research_billing_qty of 0 when unchecked" do
      line_item = LineItem.where(arm: @arm).first
      put :check_row, {
        line_item_id: line_item.id,
        check: 'false',
        format: :js
      }
      visit_count = Visit.where(line_item_id: line_item.id).where(research_billing_qty: 0).count
      expect(visit_count).to eq(@arm.visit_count)
    end
  end

  describe "PUT #check_column" do
    it "should set all visits for the visit_group to have a research_billing_qty of 1 when checked" do
      visit_group = VisitGroup.first
      put :check_column, {
        visit_group_id: visit_group.id,
        check: 'true',
        format: :js
      }
      visit_count = Visit.where(visit_group_id: visit_group.id).where(research_billing_qty: 1).count
      expect(visit_count).to eq(@arm.line_items.count)
    end

    it "should set all visits for the visit_group to have a research_billing_qty of 0 when unchecked" do
      visit_group = VisitGroup.first
      put :check_column, {
        visit_group_id: visit_group.id,
        check: 'false',
        format: :js
      }
      visit_count = Visit.where(visit_group_id: visit_group.id).where(research_billing_qty: 0).count
      expect(visit_count).to eq(@arm.line_items.count)
    end
  end

  describe "PUT #remove_line_item" do
    it "should remove the line_item from the arm" do
      #Todo this needs to be updated when merged with Charlie's branch
    end
  end
end