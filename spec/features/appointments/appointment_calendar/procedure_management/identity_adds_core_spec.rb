require 'rails_helper'

feature 'User adds a Procedure to an unstarted visit', js: true do

  before :each do
    @protocol     = create_and_assign_protocol_to_me
    @participant  = Participant.first
    @appointment  = Appointment.first
    @services     = @protocol.organization.inclusive_child_services(:per_participant)
  end

	scenario 'and sees that a core has been created' do
    given_i_am_viewing_a_visit
    when_i_add_2_procedures_to_same_group
		then_i_should_see_a_new_core_created
	end 

  scenario 'and sees that the entire multiselect dropdown is disabled' do
    given_i_am_viewing_a_visit
    when_i_add_2_procedures_to_same_group
  	then_i_should_see_that_the_multiselect_dropdown_is_disabled
	end

  scenario 'and sees that the incomplete button is disabled' do
    given_i_am_viewing_a_visit
    when_i_add_2_procedures_to_same_group
    then_i_should_see_that_it_the_incomplete_button_is_disabled
  end

  scenario 'and sees that the complete button is disabled' do
    given_i_am_viewing_a_visit
    when_i_add_2_procedures_to_same_group
    then_i_should_see_that_it_the_complete_button_is_disabled
  end

  def when_i_add_2_procedures_to_same_group
    add_a_procedure @services.first, 2
  end

  def then_i_should_see_a_new_core_created
  	expect(page).to have_css('.core')
  end

  def then_i_should_see_that_the_multiselect_dropdown_is_disabled
  	expect(page).to have_css('button.multiselect.disabled')
  end

  def then_i_should_see_that_it_the_incomplete_button_is_disabled
  	expect(page).to have_css('button.complete_all.disabled')
  end

  def then_i_should_see_that_it_the_complete_button_is_disabled
  	expect(page).to have_css('button.incomplete_all.disabled')
  end
end
