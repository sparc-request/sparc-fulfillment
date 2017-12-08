# Copyright © 2011-2017 MUSC Foundation for Research Development~
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
    @identity    = Identity.first
    participant  = protocol.participants.first
    @visit_group = participant.appointments.first.visit_group
    @service     = protocol.organization.inclusive_child_services(:per_participant).first

    visit participant_path participant
    wait_for_ajax
    
    bootstrap_select '#appointment_select', @visit_group.name
    wait_for_ajax
  end

  def when_i_add_a_procedure
    bootstrap_select '#service_list', @service.name
    fill_in 'service_quantity', with: 1
    click_button 'Add Service'
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
    find('button.start_visit').click
    wait_for_ajax
  end

  def when_i_complete_the_procedure
    find("tr.procedure[data-id='#{@procedure.id}'] label.status.complete").click
    wait_for_ajax
  end

  def when_i_incomplete_the_procedure
    find("tr.procedure[data-id='#{@procedure.id}'] label.status.incomplete").click
    bootstrap_select '#procedure_notes_attributes_0_reason', 'Assessment missed'
    click_button 'Save'
    wait_for_ajax
  end

  def when_i_add_a_follow_up_date
    find("tr.procedure[data-id='#{@procedure.id}'] button.followup.new").click
    wait_for_ajax

    bootstrap_select '#task_assignee_id', @identity.full_name

    page.execute_script %Q{ $("#follow_up_procedure_datepicker").trigger("focus")}
    page.execute_script %Q{ $("td.day:contains('10')").trigger("click") }
    fill_in 'Comment', with: 'Test comment'
    click_button 'Save'
    wait_for_ajax
  end

  def then_i_should_be_able_to_complete_visit
    expect(page).not_to have_css("button.complete_visit.disabled")
    find("button.complete_visit").click
    wait_for_ajax
    # completed date input should be visible after clicking Complete Visit
    expect(page).not_to have_css('div.completed_date_input.hidden')
  end

  def then_i_should_not_be_able_to_complete_visit
    accept_alert do
      find("button.complete_visit.disabled").trigger('click')
    end
    wait_for_ajax
  end

  def when_i_view_the_procedures_in_the_group
    find('tr.procedure-group button').click
    wait_for_ajax
  end
end
