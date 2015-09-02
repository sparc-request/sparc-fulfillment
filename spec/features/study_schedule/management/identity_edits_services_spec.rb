require 'rails_helper'

feature 'Identity edits services for a particular protocol', js: true, enqueue: false do

  context 'User adds a service to an arm' do
    context 'and fills the form out correctly' do
      scenario 'and sees the service on the arm' do
        given_i_am_viewing_a_protocol
        given_an_arm_has_services
        when_i_click_the_add_services_button
        when_i_fill_in_the_form
        when_i_click_the_add_submit_button
        then_i_should_see_it_on_that_arm
      end

      scenario 'and sees a flash message' do
        given_i_am_viewing_a_protocol
        given_an_arm_has_services
        when_i_click_the_add_services_button
        when_i_fill_in_the_form
        when_i_click_the_add_submit_button
        then_i_should_see_a_flash_message_of_type 'add'
      end
    end

    context 'and fills the form out incorrectly' do
      scenario 'and sees some errors' do
        given_i_am_viewing_a_protocol
        given_an_arm_has_services
        when_i_click_the_add_services_button
        when_i_click_the_add_submit_button
        then_i_should_see_some_errors_of_type 'add'
      end
    end
  end

  context 'User deletes a service from an arm' do
    context 'and fills out the form correctly' do
      scenario 'and sees the service is gone' do
        given_i_am_viewing_a_protocol
        given_an_arm_has_services
        when_i_click_the_remove_services_button
        when_i_select_a_service_and_arm
        when_i_click_the_remove_submit_button
        then_i_should_not_see_it_on_that_arm
      end

      scenario 'and sees a flash message' do
        given_i_am_viewing_a_protocol
        given_an_arm_has_services
        when_i_click_the_remove_services_button
        when_i_select_a_service_and_arm
        when_i_click_the_remove_submit_button
        then_i_should_see_a_flash_message_of_type 'remove'
      end
    end

    context 'and fills out the form incorrectly' do
      scenario 'and sees some errors' do
        given_i_am_viewing_a_protocol
        given_an_arm_has_services
        when_i_click_the_remove_services_button
        when_i_click_the_remove_submit_button
        then_i_should_see_some_errors_of_type 'remove'
      end
    end

    context 'which has completed procedures' do
      scenario 'and sees some errors' do
        given_i_am_viewing_a_protocol
        given_an_arm_has_services
        given_a_service_has_completed_procedures
        when_i_click_the_remove_services_button
        when_i_select_a_service_and_arm
        when_i_click_the_remove_submit_button
        then_i_should_see_some_errors_of_type 'remove with complete procedures'
      end
    end
  end

  def given_i_am_viewing_a_protocol
    @protocol  = create_and_assign_protocol_to_me
    @protocol.arms.each{|a| a.delete}
    @protocol.line_items.each{|li| li.delete}
    @services  = @protocol.organization.inclusive_child_services(:per_participant)
    @arm       = create(:arm_with_visit_groups, protocol: @protocol)
    @line_item = create(:line_item, arm: @arm, service: @services.first, protocol: @protocol)

    visit protocol_path @protocol
  end

  def given_an_arm_has_services
    Service.all.each do |s| #Clean up services otherwise service may not show up unless list scrolled
      s.delete if !@services.include?(s)
    end
  end

  def given_a_service_has_completed_procedures
    participant  = create(:participant_with_appointments, protocol: @protocol, arm: @arm)
    procedure    = create(:procedure_complete, service: @services.first, appointment: participant.appointments.first, arm: @arm, status: "complete", completed_date: "10-09-2010")
  end

  def when_i_click_the_add_services_button
    find("#add_service_button").click
  end

  def when_i_click_the_remove_services_button
    find("#remove_service_button").click
    wait_for_ajax
  end

  def when_i_fill_in_the_form
    bootstrap_select "#add_service_id", "#{@services.last.name}"
    
    bootstrap_select "#add_service_arm_ids_and_pages_", @arm.name
    find("h4#line_item").click # click out of bootstrap multiple select
  end

  def when_i_select_a_service_and_arm
    bootstrap_select "#remove_service_id", "#{@services.first.name}"
    find("h4#line_item").click # click out of bootstrap multiple select

    bootstrap_select "#remove_service_arm_ids_", "#{@arm.name}"
    find("h4#line_item").click # click out of bootstrap multiple select
  end

  def when_i_click_the_add_submit_button
    click_button "Add"
  end

  def when_i_click_the_remove_submit_button
    click_button "Remove"
  end

  def then_i_should_see_it_on_that_arm
    arm = find(".arm_#{@arm.id}")
    expect(arm).to have_content "#{@services.last.name}"
  end

  def then_i_should_not_see_it_on_that_arm
    arm = find(".arm_#{@arm.id}")
    expect(arm).not_to have_content "#{@services.first.name}"
  end

  def then_i_should_see_some_errors_of_type action_type
    service_name = @protocol.organization.inclusive_child_services(:per_participant).first.name
    arm_name = @arm.name
    case action_type
      when 'add'
        expect(page).to have_content("Arms to add '#{service_name}' to must be selected")
      when 'remove'
        expect(page).to have_content("Arms to remove '#{service_name}' from must be selected")
      when 'remove with complete procedures'
        expect(page).to have_content("Service '#{service_name}' on Arm '#{arm_name}' has completed procedures and cannot be deleted")
    end
  end

  def then_i_should_see_a_flash_message_of_type action_type
    case action_type
      when 'add'
        expect(page).to have_content("Service(s) have been added to the chosen arms")
      when 'remove'
        expect(page).to have_content("Service(s) have been removed from the chosen arms")
    end
  end
end
