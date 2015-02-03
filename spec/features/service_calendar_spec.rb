require 'rails_helper'

RSpec.describe 'Service Calendar', type: :feature, js: true do

  let!(:protocol)    { create(:protocol) }
  let!(:arm)         { create(:arm_imported_from_sparc, protocol_id: protocol.id, visit_count: 10)}

  before :each do
    @line_item = arm.line_items.first
    @visit_group = arm.visit_groups.first
    @visit = @line_item.visits.first
    visit protocol_path(protocol.sparc_id)
  end

  it 'should display the calendar with visit names, line items, and visits' do
    expect(page).to have_css(".calendar.service.arm_#{arm.id}")
    expect(page).to have_css("#visit_group_#{@visit_group.id}")
    expect(page).to have_css("#line_item_#{@line_item.id}")
    expect(page).to have_css("#visit_check_#{@visit.id}")
  end

  it "should change tabs when a new tab is selected" do
    click_link "Quantity/Billing Tab"
    wait_for_javascript_to_finish
    expect(page).to have_css("#visits_#{@visit.id}_research_billing_qty")
    expect(page).to have_css("#visits_#{@visit.id}_insurance_billing_qty")
  end

  describe "removing a line_item" do

    it "should remove the line item" do
      within("#line_item_#{@line_item.id}") do
        find(".remove_line_item").click()
      end
      expect(page).not_to have_css("#line_item_#{@line_item.id}")
    end

    it "should remove the core when all line items for that core have been removed" do
      arm.line_items.each do |line_item|
        within("#line_item_#{line_item.id}") do
          find(".remove_line_item").click()
        end
      end
      expect(page).not_to have_css("#arm_#{arm.id}_core_#{@line_item.sparc_core_id}")
    end

  end

  describe "changing pages" do
    it "should disable the previous button on the first page" do
      expect(page).to have_css("#arrow-left-#{arm.id}[disabled]")
    end

    it "should disable the next button on the last page" do
      find("#arrow-right-#{arm.id}").click()
      wait_for_javascript_to_finish
      expect(page).to have_css("#arrow-right-#{arm.id}[disabled]")
    end

    it "should change to the next page when the next button is clicked" do
      find("#arrow-right-#{arm.id}").click()
      wait_for_javascript_to_finish
      expect(page).to have_css("#visit_check_#{@line_item.visits.last.id}")
    end

    it "should change to the previous page when the previous button is clicked" do
      find("#arrow-right-#{arm.id}").click()
      wait_for_javascript_to_finish
      find("#arrow-left-#{arm.id}").click()
      wait_for_javascript_to_finish
      expect(page).to have_css("#visit_check_#{@visit.id}")
    end

    it "should jump to the correct page when picked from the dropdown" do
    end
  end

  describe "template tab" do

    describe "check row button" do

      it "should check all visits for the line item when check is clicked" do
        within("#line_item_#{@line_item.id}") do
          find(".check_row").click()
          wait_for_javascript_to_finish
          expect(all('input[type=checkbox]:checked').count).to eq(Visit.per_page)
        end
      end

      it "should uncheck all visits for the line item when uncheck is clicked" do
        within("#line_item_#{@line_item.id}") do
          find(".check_row").click()
          wait_for_javascript_to_finish
          find(".check_row").click()
          wait_for_javascript_to_finish
          expect(all('input[type=checkbox]:checked').count).to eq(0)
        end
      end

    end

    describe "check column button" do

      it "should check all visits for the visit group when check is clicked" do
        first(".check_column").click()
        wait_for_javascript_to_finish
        expect(all('input[type=checkbox]:checked').count).to eq(@visit_group.visits.count)
      end

      it "should uncheck all visits for the visit group when uncheck is clicked" do
        first(".check_column").click()
        wait_for_javascript_to_finish
        first(".check_column").click()
        wait_for_javascript_to_finish
        expect(all('input[type=checkbox]:checked').count).to eq(0)
      end

    end

  end

  describe "quantity tab" do
    before :each do
      click_link 'Quantity/Billing Tab'
    end

    describe "changing quantities" do
      it "should set the quantity back to the previous quantity if nothing is entered" do
        fill_in "visits_#{@visit.id}_research_billing_qty", :with => '6'
        first('.calendar.service').click()
        wait_for_javascript_to_finish
        fill_in "visits_#{@visit.id}_research_billing_qty", with: ''
        first('.calendar.service').click()
        expect(find_field("visits_#{@visit.id}_research_billing_qty").value).to eq('6')
      end
    end

    describe "check row button" do

      it "should set research fields to 1 and insurance fields to 0 for the line item when check is clicked" do
        within("#line_item_#{@line_item.id}") do
          find(".check_row").click()
          wait_for_javascript_to_finish
          all('.research').each do |quantity|
            expect(quantity.value).to eq('1')
          end
        end
      end

      it "should set research fields to 0 and insurance fields to 0 for the line item  when uncheck is clicked" do
        within("#line_item_#{@line_item.id}") do
          find(".check_row").click()
          wait_for_javascript_to_finish
          find(".check_row").click()
          wait_for_javascript_to_finish
          all('.research').each do |quantity|
            expect(quantity.value).to eq('0')
          end
        end
      end

    end

    describe "check column button" do

      it "should set research fields to 1 and insurance fields to 0 for the visit group when check is clicked" do
        first(".check_column").click()
        wait_for_javascript_to_finish
        expect(find("#visits_#{@visit.id}_research_billing_qty").value).to eq('1')
        expect(find("#visits_#{@visit.id}_insurance_billing_qty").value).to eq('0')
      end

      it "should set research fields to 0 and insurance fields to 0 for the visit group when uncheck is clicked" do
        first(".check_column").click()
        wait_for_javascript_to_finish
        first(".check_column").click()
        wait_for_javascript_to_finish
        expect(find("#visits_#{@visit.id}_research_billing_qty").value).to eq('0')
        expect(find("#visits_#{@visit.id}_insurance_billing_qty").value).to eq('0')
      end

    end

  end

  describe "consolidated tab" do

  end
end