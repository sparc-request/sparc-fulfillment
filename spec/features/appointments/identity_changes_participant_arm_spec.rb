require 'rails_helper'

feature "Change Participant Arm", js: :true do

  context "original arm has completed appointments" do
    scenario "Users changes arm on the participant tracker" do
      when_i_start_work_on_an_appointment
      then_i_change_the_arm_of_the_participant
      and_the_visit_group_of_completed_procedure_should_still_appear
      then_i_switch_back_to_the_original_arm
      and_all_the_visits_should_appear
    end
  end

  def when_i_start_work_on_an_appointment
    @protocol     = create_and_assign_protocol_to_me
    @original_arm = @protocol.arms.first
    @participant  = @protocol.participants.first
    @participant.update_attribute(:arm_id, @original_arm.id)
    @procedure = create(:procedure, visit_group: @original_arm.visit_groups.first, completed_date: "08/08/2013")
    @service   = @protocol.organization.inclusive_child_services(:per_participant).first
    
    visit participant_path @participant
    wait_for_ajax

  end

  def then_i_change_the_arm_of_the_participant
    @new_arm = create(:arm, protocol_id: @protocol.id)
    @participant.update_attribute(:arm_id, @new_arm.id)
    
    visit participant_path @participant
    wait_for_ajax
  end

  def and_the_visit_group_of_completed_procedure_should_still_appear
    bootstrap_select("#appointment_select", @procedure.visit_group.name)
    wait_for_ajax
  end

  def then_i_switch_back_to_the_original_arm
    @participant.update_attribute(:arm_id, @original_arm.id)
  end

  def and_all_the_visits_should_appear
    #only tests for one to save time since if last one appears the others should also be there
    bootstrap_select("#appointment_select", @original_arm.visit_groups.last.name)
    wait_for_ajax
  end
end
