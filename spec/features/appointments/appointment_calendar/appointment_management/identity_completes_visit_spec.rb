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

feature 'Complete Visit', js: true do

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
          when_i_add_a_procedure #**The extra procedure**#
          when_i_begin_the_appointment
          then_i_should_not_be_able_to_complete_visit
        end
      end
    end
  end

  def given_i_am_viewing_an_appointment
    protocol     = create_and_assign_protocol_to_me
    protocols_participant  = protocol.protocols_participants.first
    @visit_group = protocols_participant.appointments.first.visit_group
    @service     = protocol.organization.inclusive_child_services(:per_participant).first

    visit calendar_protocol_participant_path(id: protocols_participant.id, protocol_id: protocol)
    
    expect(page).to have_css('a.list-group-item.appointment-link')
    first('a.list-group-item.appointment-link').click
    
    # NATIVE SYNC: Wait for the AJAX pane to finish loading.
    # The 'addService' button might already be visible from a previous state, 
    # so we assert the page contains the specific Visit Group's name to prove the new data arrived.
    expect(page).to have_content(@visit_group.name)
    expect(page).to have_css('button#addService')
  end

  def when_i_add_a_procedure
    bootstrap_select('.form-control.selectpicker', @service.name)
    
    # The Ghost Click Barrier
    retries = 0
    begin
      find('button#addService').click
      
      # Wait up to 3 seconds for the network request to append the row
      expect(page).to have_css("tr", text: @service.name, wait: 3)
      
    rescue RSpec::Expectations::ExpectationNotMetError => e
      # If the row never appears, the JS event listener missed our click. 
      # The DOM has settled by now, so we click it again.
      retry if (retries += 1) < 3
      raise e
    end

    @visit_group.appointments.first.procedures.reload
    @procedure = @visit_group.appointments.first.procedures.where(service_id: @service.id).first
  end

  def when_i_remove_the_procedure
    accept_confirm do
      find("tr[data-id='#{@procedure.id}'] button.delete").click
    end
    # Native sync: Wait for the row to vanish from the DOM
    expect(page).to have_no_css("tr[data-id='#{@procedure.id}']")
  end

  def when_i_begin_the_appointment
    find('a.btn.start-appointment').click
    expect(page).to have_no_css('a.btn.start-appointment')

    first('a.list-group-item, a.visit-group-link', text: @visit_group.name).click
    # Wait for the view to switch to the active appointment
    expect(page).to have_css("button.complete-appointment") 
  end

  def when_i_complete_the_procedure
    find("button.btn-sq.complete-btn").click
    # Native sync: Wait for the UI to flip to the incomplete button state
    expect(page).to have_css("button.btn-sq.incomplete-btn")
  end

  def when_i_incomplete_the_procedure
    find("button.btn-sq.incomplete-btn").click
    
    # Wait for the modal to fully appear in the DOM
    expect(page).to have_selector('.modal-header', text: 'New Procedure Note')
    
    bootstrap_select '#procedure_notes_attributes_0_reason', 'Assessment missed'
    
    # Ghost Click Barrier for Modal Submission
    retries = 0
    begin
      within '.modal-footer' do
        click_button 'Submit'
      end
      
      # Wait up to 4 seconds for the backend to process and the modal to vanish
      expect(page).to have_no_selector('.modal-backdrop', wait: 4)
      expect(page).to have_no_selector('.modal', wait: 4)
      
    rescue RSpec::Expectations::ExpectationNotMetError => e
      # If the modal is still open, we likely clicked mid-animation. 
      # The modal is stationary now, so click again.
      retry if (retries += 1) < 2
      raise e
    end
  end

  def when_i_add_a_follow_up_date
    within(page.find("tr", text: @service.name)) do
      find("i.fa-calendar-alt, i.fa-calendar").click
    end

    expect(page).to have_selector('#modalContainer.show')
    
    bootstrap_select '#task_assignee_id', @logged_in_identity.full_name

    # RESTORED JS INJECTION: Datepickers aggressively block standard typing.
    # This guarantees the form receives the value so validation passes.
    page.execute_script %Q{ 
      $('#task_due_at').val("#{Date.today.strftime('%m/%d/%Y')}");
      $('#task_due_at').trigger('change');
    }

    fill_in 'task_notes_comment', with: 'Test comment'
    
    # Ghost Click Barrier for Modal Submission
    retries = 0
    begin
      within '.modal-footer' do
        click_button 'Submit'
      end
      
      expect(page).to have_no_selector('#modalContainer.show', wait: 4)
      expect(page).to have_no_selector('.modal-backdrop', wait: 4)
      
    rescue RSpec::Expectations::ExpectationNotMetError => e
      retry if (retries += 1) < 2
      raise e
    end
  end

  def then_i_should_be_able_to_complete_visit
    # We already verified the modal closed in the previous step, so we just check the button.
    expect(page).not_to have_css("button.complete_visit.disabled")
    
    find("button.complete-appointment").click
    
    # completed date input should be visible after clicking Complete Visit
    expect(page).not_to have_css('div.completed_date_input.hidden')
  end

  def then_i_should_not_be_able_to_complete_visit
    expect(page).to have_css("button.disabled")
  end
end
