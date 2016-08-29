require 'rails_helper'

feature 'Identity adds service to completed visit', js: :true do

  describe 'user adds a service' do

    it 'should not create procedures for a completed visit' do
      protocol  = create_and_assign_protocol_to_me
      protocol.arms.each{|a| a.delete}
      protocol.line_items.each{|li| li.delete}
      services  = protocol.organization.inclusive_child_services(:per_participant)
      arm       = create(:arm_with_visit_groups, protocol: protocol)
      line_item = create(:line_item, arm: arm, service: services.first, protocol: protocol)
      participant  = create(:participant_with_completed_appointments,
                            protocol: protocol,
                            arm: protocol.arms.first)

      visit protocol_path protocol
      wait_for_ajax
      visit_id = VisitGroup.first.id
      procedure_count = Procedure.all.count

      find("#line_item_#{line_item.id} .check_row").click
      wait_for_ajax

      expect(Procedure.all.count).to eq(procedure_count)
    end
  end
end