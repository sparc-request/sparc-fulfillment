require 'rails_helper'

RSpec.describe 'Study Schedule', type: :feature, js: true do

  before :each do
    @protocol       = create_and_assign_blank_protocol_to_me
    project_role    = create(:project_role_pi, protocol: @protocol)
    @arm            = create(:arm_with_only_per_patient_line_items, protocol: @protocol, visit_count: 10)
    @line_item      = @arm.line_items.first
    @visit_group    = @arm.visit_groups.first
    @visit          = @line_item.visits.first
    visit protocol_path(@protocol.id)
  end

  it 'should display the study schedule with visit names, line items, and visits' do
    expect(page).to have_css(".study_schedule.service.arm_#{@arm.id}")
    expect(page).to have_css("#visit-name-display-#{@visit_group.id}")
    expect(page).to have_css("#line_item_#{@line_item.id}")
    expect(page).to have_css("#visit_check_#{@visit.id}")
  end

  it "should change tabs when a new tab is selected" do
    click_link "Quantity/Billing Tab"
    wait_for_ajax
    expect(page).to have_css("#visits_#{@visit.id}_research_billing_qty")
    expect(page).to have_css("#visits_#{@visit.id}_insurance_billing_qty")
  end

  describe "visit group name fields" do

    it "should set the name back to the previous name if there is a validation error" do
      fill_in "visit_group_#{@visit_group.id}", with: 'vanilla ice cream'
      first('.study_schedule.service').click()
      wait_for_ajax
      fill_in "visit_group_#{@visit_group.id}", with: ''
      first('.study_schedule.service').click()
      expect(find_field("visit_group_#{@visit_group.id}").value).to eq('vanilla ice cream')
    end
  end

  describe "changing pages" do
    it "should disable the previous button on the first page" do
      expect(page).to have_css("#arrow-left-#{@arm.id}[disabled]")
    end

    it "should disable the next button on the last page" do
      find("#arrow-right-#{@arm.id}").click()
      wait_for_ajax
      expect(page).to have_css("#arrow-right-#{@arm.id}[disabled]")
    end

    it "should change to the next page when the next button is clicked" do
      find("#arrow-right-#{@arm.id}").click()
      wait_for_ajax
      expect(page).to have_css("#visit_check_#{@line_item.visits.last.id}")
    end

    it "should change to the previous page when the previous button is clicked" do
      find("#arrow-right-#{@arm.id}").click()
      wait_for_ajax
      find("#arrow-left-#{@arm.id}").click()
      wait_for_ajax
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
          wait_for_ajax
          expect(all('input[type=checkbox]:checked').count).to eq(Visit.per_page)
        end
      end

      it "should uncheck all visits for the line item when uncheck is clicked" do
        within("#line_item_#{@line_item.id}") do
          find(".check_row").click()
          wait_for_ajax
          find(".check_row").click()
          wait_for_ajax
          expect(all('input[type=checkbox]:checked').count).to eq(0)
        end
      end

    end

    describe "check column button" do

      it "should check all visits for the visit group when check is clicked" do
        first(".check_column").click()
        wait_for_ajax
        expect(all('input[type=checkbox]:checked').count).to eq(@arm.line_items.count)
      end

      it "should uncheck all visits for the visit group when uncheck is clicked" do
        first(".check_column").click()
        wait_for_ajax
        first(".check_column").click()
        wait_for_ajax
        expect(all('input[type=checkbox]:checked').count).to eq(0)
      end

    end

  end

  describe "quantity tab" do
    before :each do
      click_link 'Quantity/Billing Tab'
      wait_for_ajax
    end

    describe "changing quantities" do
      it "should set the quantity back to the previous quantity if nothing is entered" do
        fill_in "visits_#{@visit.id}_research_billing_qty", :with => '6'
        first('.study_schedule.service').click()
        wait_for_ajax
        fill_in "visits_#{@visit.id}_research_billing_qty", with: ''
        first('.study_schedule.service').click()
        expect(find_field("visits_#{@visit.id}_research_billing_qty").value).to eq('6')
      end

      it "should set the quantity back to the previous quantity if there is a validation error" do
        fill_in "visits_#{@visit.id}_research_billing_qty", :with => '6'
        first('.study_schedule.service').click()
        wait_for_ajax
        fill_in "visits_#{@visit.id}_research_billing_qty", with: '-1'
        first('.study_schedule.service').click()
        expect(find_field("visits_#{@visit.id}_research_billing_qty").value).to eq('6')
      end
    end

    describe "check row button" do

      it "should set research fields to 1 and insurance fields to 0 for the line item when check is clicked" do
        within("#line_item_#{@line_item.id}") do
          find(".check_row").click()
          wait_for_ajax
          all('.research').each do |quantity|
            expect(quantity.value).to eq('1')
          end
        end
      end

      it "should set research fields to 0 and insurance fields to 0 for the line item  when uncheck is clicked" do
        within("#line_item_#{@line_item.id}") do
          wait_for_ajax
          find(".check_row").click()
          wait_for_ajax
          find(".check_row").click
          wait_for_ajax
          all('.research').each do |quantity|
            expect(quantity.value).to eq('0')
          end
        end
      end

    end

    describe "check column button" do

      it "should set research fields to 1 and insurance fields to 0 for the visit group when check is clicked" do
        first(".check_column").click()
        wait_for_ajax
        expect(find("#visits_#{@visit.id}_research_billing_qty").value).to eq('1')
        expect(find("#visits_#{@visit.id}_insurance_billing_qty").value).to eq('0')
      end

      it "should set research fields to 0 and insurance fields to 0 for the visit group when uncheck is clicked" do
        wait_for_ajax
        first(".check_column").click()
        wait_for_ajax
        first(".check_column").click()
        wait_for_ajax
        expect(find("#visits_#{@visit.id}_research_billing_qty").value).to eq('0')
        expect(find("#visits_#{@visit.id}_insurance_billing_qty").value).to eq('0')
      end
    end

    describe "editing a line item" do

      before :each do
        first(".change_line_item_service").click
        wait_for_ajax
      end

      it "should bring up the line item edit modal" do
        expect(page).to have_content("Change Service")
      end
    end
  end
end
