require 'rails_helper'

RSpec.describe 'Appointment calendar spec', type: :feature, js: true do
  let!(:protocol1)    { create(:protocol) }
  let!(:arm1)         { create(:arm, protocol: protocol1)}
  let!(:service1)     { create(:service) }
  let!(:line_item1)   { create(:line_item, service: service1, arm: arm1)}
  let!(:visit_group1) { create(:visit_group, arm: arm1) }
  let!(:visit1)       { create(:visit, visit_group: visit_group1, line_item: line_item1)}
  let!(:participant1) { create(:participant, protocol: protocol1, arm: arm1) }
  let!(:appointment1) { create(:appointment, name: 'dat procedure', visit_group_id: visit_group1.id, participant_id: participant1.id)}
  let!(:procedure1)   { create(:procedure_complete, status: 'complete', appointment_id: appointment1.id, visit_id: visit1.id, service_id: service1.id, sparc_core_name: service1.sparc_core_name, sparc_core_id: service1.sparc_core_id)}

  before :each do
    visit protocol_participant_path(protocol1.id, participant1.id)
    bootstrap_select("#appointment_select", "dat procedure")
  end

  describe "the complete and incomplete radio buttons" do
    describe "the incomplete button" do
      it "should render a modal when incomplete is selected" do
        find("#status_incomplete_#{procedure1.id}").click
        expect(page).to have_css "h4.modal-title.text-center", text: "Reason for Incompletion"
      end
      it "should not affect the previous radio button setting if the modal is closed" do
        choose "status_incomplete_#{procedure1.id}"
        click_button "close_incomplete"
        find("#status_complete_#{procedure1.id}").should be_checked
      end

      it "should submit the incomplete procedure form" do
        choose "status_incomplete_#{procedure1.id}"
        click_button 'Save'
        find("#status_incomplete_#{procedure1.id}").should be_checked
      end
    end
  end
end
