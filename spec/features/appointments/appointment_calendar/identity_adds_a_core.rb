require 'rails_helper'

feature 'Identity adds a Procedure', js: true do

  let!(:protocol)     { create_and_assign_protocol_to_me }
  let!(:participant)  { Participant.first }
  let!(:appointment)  { Appointment.first }
  let!(:services)     { protocol.organization.inclusive_child_services(:per_participant) }

	context 'in an unstarted Visit' do
    before do
      given_i_am_viewing_a_visit
      when_i_add_2_procedures_to_same_group
  	end

  	scenario 'and sees that a core has been created' do
  		then_i_should_see_a_new_core_created
  	end 

    scenario 'and sees that the entire multiselect dropdown and buttons are disabled' do
    	then_i_should_see_that_the_multiselect_dropdown_is_disabled
    	then_i_should_see_that_it_the_incomplete_button_is_disabled
    	then_i_should_see_that_it_the_complete_button_is_disabled
  	end
  end

  def when_i_add_2_procedures_to_same_group
    add_a_procedure services.first, 2
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
