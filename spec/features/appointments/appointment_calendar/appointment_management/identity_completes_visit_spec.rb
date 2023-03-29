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
    wait_for_ajax
    
    first('a.list-group-item.appointment-link').click
    wait_for_ajax
  end

  def when_i_add_a_procedure
    bootstrap_select('.form-control.selectpicker', @service.name)
    page.find('button#addService').click
    wait_for_ajax

    @visit_group.appointments.first.procedures.reload
    @procedure = @visit_group.appointments.first.procedures.where(service_id: @service.id).first
  end

  def when_i_remove_the_procedure
    accept_confirm do
      find("tr[data-id='#{@procedure.id}'] button.delete").click
    end
    wait_for_ajax
  end

  def when_i_begin_the_appointment
    find('a.btn.start-appointment').click
    wait_for_ajax
  end

  def when_i_complete_the_procedure
    find("button.btn-sq.complete-btn").click
    wait_for_ajax
  end

  def when_i_incomplete_the_procedure
    find("button.btn-sq.incomplete-btn").click
    bootstrap_select '#procedure_notes_attributes_0_reason', 'Assessment missed'
    click_button 'Submit'
    wait_for_ajax
  end

  def when_i_add_a_follow_up_date
    find("td.followup").click
    wait_for_ajax
    bootstrap_select '#task_assignee_id', @logged_in_identity.full_name
    bootstrap_datepicker '#task_due_at', day: '10'
    fill_in 'task_notes_comment', with: 'Test comment'
    click_button 'Submit'
    wait_for_ajax
  end

  def then_i_should_be_able_to_complete_visit
    expect(page).not_to have_css("button.complete_visit.disabled")
    find("button.complete-appointment").click
    wait_for_ajax
    # completed date input should be visible after clicking Complete Visit
    expect(page).not_to have_css('div.completed_date_input.hidden')
  end

  def then_i_should_not_be_able_to_complete_visit
    expect(page).to have_css("button.disabled")
    wait_for_ajax
  end
end
