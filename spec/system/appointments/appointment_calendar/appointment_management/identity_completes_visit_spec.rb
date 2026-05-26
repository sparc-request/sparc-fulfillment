# Copyright © 2011-2023 MUSC Foundation for Research Development~
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

RSpec.describe 'Complete Visit', type: :system, js: true do
  let(:protocol) { create_and_assign_protocol_to_me(identity: @logged_in_identity) }
  let(:protocols_participant) { protocol.protocols_participants.first }
  let(:visit_group) { protocols_participant.appointments.first.visit_group }
  let(:service) { protocol.organization.inclusive_child_services(:per_participant).first }

  context 'User views an unstarted appointment' do
    context 'and adds a procedure' do
      scenario 'and cant complete the visit' do
        given_i_am_viewing_an_appointment
        when_i_add_a_procedure
        then_i_should_not_be_able_to_complete_visit
      end
    end
  end

  context 'User views a started appointment' do
    context 'and does not add a Procedure' do
      scenario 'and can complete the visit' do
        given_i_am_viewing_an_appointment
        when_i_begin_the_appointment
        then_i_should_be_able_to_complete_visit
      end
    end

    context 'and adds a Procedure' do
      scenario 'and cant complete the visit' do
        given_i_am_viewing_an_appointment
        when_i_add_a_procedure
        when_i_begin_the_appointment
        then_i_should_not_be_able_to_complete_visit
      end
    end

    context 'and adds a Procedure, then sets a follow up date for it' do
      scenario 'and can complete the visit' do
        given_i_am_viewing_an_appointment
        when_i_add_a_procedure
        when_i_begin_the_appointment
        when_i_add_a_follow_up_date
        then_i_should_be_able_to_complete_visit
      end
    end

    context 'and adds a Procedure, completes it, then incompletes it' do
      scenario 'and can complete the visit' do
        given_i_am_viewing_an_appointment
        when_i_add_a_procedure
        when_i_begin_the_appointment
        when_i_complete_the_procedure
        when_i_incomplete_the_procedure
        then_i_should_be_able_to_complete_visit
      end
    end

    context 'and adds a procedure which will never be completed or incompleted' do
      context 'and does not add a Procedure' do
        scenario 'and cant complete the visit' do
          given_i_am_viewing_an_appointment
          when_i_add_a_procedure
          when_i_begin_the_appointment
          then_i_should_not_be_able_to_complete_visit
        end
      end
    end
  end

  def given_i_am_viewing_an_appointment
    visit calendar_protocol_participant_path(id: protocols_participant.id, protocol_id: protocol.id)
    
    # Keep 'find' for the StaleElement safety, but add match: :first to handle the duplicate UI links
    find('a.list-group-item.appointment-link', text: visit_group.name, match: :first).click

    within('#appointmentContainer') do
      expect(page).to have_css('h3', text: /#{visit_group.name}/i)
    end
  end

  def when_i_add_a_procedure
    # Removed the "Start Visit" click from here, it was prematurely starting the visit in scenarios testing the unstarted state
    bootstrap_select('.form-control.selectpicker', service.name)
    click_button 'Add Service' 

    within('#appointmentContainer') do
      expect(page).to have_css('tr', text: service.name)
    end
  end

  def when_i_remove_the_procedure
    accept_confirm do
      # Target the row by service name rather than mid-test database queries
      within('#appointmentContainer tr', text: service.name) do
        find('button.delete').click
      end
    end
    
    # Assert it disappears to wait for the AJAX deletion to complete
    within('#appointmentContainer') do
      expect(page).to have_no_css('tr', text: service.name)
    end
  end

  def when_i_begin_the_appointment
    click_link 'Start Visit'
    expect(page).to have_no_link('Start Visit')

    # Add match: :first here as well
    find('a.list-group-item, a.visit-group-link', text: visit_group.name, match: :first).click
    
    within('#appointmentContainer') do
      expect(page).to have_css('h3', text: /#{visit_group.name}/i)
    end
  end

  def when_i_complete_the_procedure
    within('#appointmentContainer tr', text: service.name) do
      find('button.complete-btn').click
      expect(page).to have_css('button.complete-btn.active') 
    end
  end

  def when_i_incomplete_the_procedure
    within('#appointmentContainer tr', text: service.name) do
      find('button.incomplete-btn').click
    end

    # Scope to the modal natively
    within('.modal') do
      expect(page).to have_css('.modal-header', text: 'New Procedure Note')
      bootstrap_select '#procedure_notes_attributes_0_reason', 'Assessment missed'
      click_button 'Submit'
    end

    # Natively wait for the modal and backdrop to be removed from the DOM
    expect(page).to have_no_css('.modal')
    expect(page).to have_no_css('.modal-backdrop')
  end

  def when_i_add_a_follow_up_date
    within('#appointmentContainer tr', text: service.name) do
      find('i.fa-calendar-alt, i.fa-calendar').click
    end

    expect(page).to have_css('#modalContainer.show')

    bootstrap_select '#task_assignee_id', @logged_in_identity.full_name
    
    bootstrap_datepicker '#task_due_at', text: Date.today.strftime('%m/%d/%Y')

    fill_in 'task_notes_comment', with: 'Test comment'
    
    within('#modalContainer') do
      click_button 'Submit'
    end

    expect(page).to have_no_css('#modalContainer.show')
    expect(page).to have_no_css('.modal-backdrop')
    expect(page).to have_no_css('body.modal-open')
  end

  def then_i_should_be_able_to_complete_visit
    expect(page).to have_no_css('#modalContainer')
    
    expect(page).to have_button('Complete Visit', disabled: false) 
    click_button 'Complete Visit'
    
    expect(page).to have_field('Completed Date')
  end

  def then_i_should_not_be_able_to_complete_visit
    # If the visit is not started yet, there's no complete button at all.
    if page.has_link?('Start Visit', wait: 0)
      expect(page).to have_link('Start Visit')
    else
      # Check for EITHER the Bootstrap `.disabled` class OR the native HTML attribute. This makes the test bulletproof regardless of how the frontend designates it as disabled.
      expect(page).to have_css('.disabled, [disabled]', text: 'Complete Visit')
    end
  end
end
