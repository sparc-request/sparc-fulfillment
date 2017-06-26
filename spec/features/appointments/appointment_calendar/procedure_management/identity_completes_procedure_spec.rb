# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

feature 'User completes Procedure', js: true do

  scenario 'and sees a completed Note' do
    given_i_have_added_a_procedure_to_an_appointment
    when_i_start_the_appointment
    when_i_complete_the_procedure
    when_i_view_the_notes_list
    then_i_should_see_complete_notes
  end

  context 'and changes their mind, clicking complete again' do
    scenario 'and sees the reset note' do
      given_i_have_completed_an_appointment
      when_i_complete_the_procedure
      when_i_view_the_notes_list
      then_i_should_see_reset_notes
    end
  end

  context 'which was previously incomplete' do
    scenario 'and sees the complete note' do
      given_i_have_added_a_procedure_to_an_appointment
      when_i_start_the_appointment
      when_i_incomplete_the_procedure
      when_i_complete_the_procedure
      when_i_view_the_notes_list
      then_i_should_see_complete_notes
    end
  end

  context 'before starting Appointment' do
    scenario 'and sees a helpful error message' do
      given_i_have_added_a_procedure_to_an_appointment
      when_i_try_to_complete_the_procedure
      then_i_should_see_a_helpful_message
    end
  end

  def given_i_have_added_a_procedure_to_an_appointment(qty=1)
    protocol    = create_and_assign_protocol_to_me
    participant = protocol.participants.first
    visit_group = participant.appointments.first.visit_group
    service     = protocol.organization.inclusive_child_services(:per_participant).first

    visit participant_path participant
    wait_for_ajax

    bootstrap_select '#appointment_select', visit_group.name
    wait_for_ajax
    
    bootstrap_select '#service_list', service.name
    fill_in 'service_quantity', with: qty
    find('button.add_service').click
    wait_for_ajax

    visit_group.appointments.first.procedures.reload
    @procedure = visit_group.appointments.first.procedures.where(service_id: service.id).first
  end

  def given_i_have_completed_an_appointment
    given_i_have_added_a_procedure_to_an_appointment
    when_i_start_the_appointment
    when_i_complete_the_procedure
  end

  def when_i_start_the_appointment
    find('button.start_visit').click
  end

  def when_i_complete_the_procedure
    find('label.status.complete').click
    wait_for_ajax
  end

  def when_i_incomplete_the_procedure
    find('label.status.incomplete').click
    wait_for_ajax
    bootstrap_select '.reason-select', "Assessment missed"
    click_button 'Save'
    wait_for_ajax
  end

  def when_i_try_to_complete_the_procedure
    @alert = accept_alert(with: 'Please click Start Visit and enter a start date to continue.') do
      find('label.status.complete').trigger('click')
      wait_for_ajax
    end
  end

  def when_i_view_the_notes_list
    find('.procedure td.notes button.notes.list').click
  end

  def then_i_should_see_complete_notes count=1
    expect(page).to have_css('.modal-body .detail .comment', text: 'Status set to complete', count: count)
  end

  def then_i_should_see_reset_notes
    expect(page).to have_css('.modal-body .detail .comment', text: 'Status reset', count: 1)
  end

  def then_i_should_see_a_helpful_message
    expect(@alert).to eq("Please click 'Start Visit' and enter a start date to continue.")
  end
end
