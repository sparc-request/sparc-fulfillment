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