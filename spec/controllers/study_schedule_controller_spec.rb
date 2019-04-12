# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

require 'rails_helper'

RSpec.describe StudyScheduleController do
  before :each do
    sign_in
    @protocol = create(:protocol)
    @arm = create(:arm_imported_from_sparc, protocol_id: @protocol.id, visit_count: 10)
  end

  describe "GET #change_page" do
    it "should change the page to the page passed in" do
      tab = 'template'
      page = 1
      get :change_page, params: {
        page: page + 1,
        arm_id: @arm.id,
        tab: tab
      }, format: :js, xhr: true
      expect(assigns(:page)).to eq(page + 1)
    end

  end

  describe "GET #change_tab" do
    it "should change the tab to the tab passed in" do
      page = 1
      get :change_tab, params: {
        arms_and_pages: {"#{@arm.id}" => page},
        tab: 'quantity',
        protocol_id: @protocol.id
      }, format: :js, xhr: true
      expect(assigns(:tab)).to eq('quantity')
    end
  end

  describe "PUT #check_row" do
    it "should set all visits for the line_item to have a research_billing_qty of 1 when checked" do
      line_item = LineItem.where(arm: @arm).first
      put :check_row, params: {
        line_item_id: line_item.id,
        check: 'true'
      }, format: :js
      visit_count = Visit.where(line_item_id: line_item.id).where(research_billing_qty: 1).count
      expect(visit_count).to eq(@arm.visit_count)
    end

    it "should set all visits for the line_item to have a research_billing_qty of 0 when unchecked" do
      line_item = LineItem.where(arm: @arm).first
      put :check_row, params: {
        line_item_id: line_item.id,
        check: 'false'
      }, format: :js
      visit_count = Visit.where(line_item_id: line_item.id).where(research_billing_qty: 0).count
      expect(visit_count).to eq(@arm.visit_count)
    end
  end

  describe "PUT #check_column" do
    it "should set all visits for the visit_group to have a research_billing_qty of 1 when checked" do
      visit_group = VisitGroup.first
      put :check_column, params: {
        visit_group_id: visit_group.id,
        check: 'true'
      }, format: :js
      visit_count = Visit.where(visit_group_id: visit_group.id).where(research_billing_qty: 1).count
      expect(visit_count).to eq(@arm.line_items.count)
    end

    it "should set all visits for the visit_group to have a research_billing_qty of 0 when unchecked" do
      visit_group = VisitGroup.first
      put :check_column, params: {
        visit_group_id: visit_group.id,
        check: 'false'
      }, format: :js
      visit_count = Visit.where(visit_group_id: visit_group.id).where(research_billing_qty: 0).count
      expect(visit_count).to eq(@arm.line_items.count)
    end
  end
end