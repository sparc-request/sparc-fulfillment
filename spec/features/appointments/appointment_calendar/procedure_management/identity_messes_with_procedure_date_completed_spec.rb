# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

feature 'User messes with a procedures date completed', js: true do

  context 'which is incomplete' do
    scenario 'and sees a disabled datepicker' do
      given_i_am_viewing_an_appointment
      when_i_add_a_procedure
      then_i_should_see_a_disabled_datepicker
    end
  end

  context 'which is complete' do
    scenario 'and sees date completed updated and enabled' do
      given_i_am_viewing_a_procedure
      given_an_appointment_has_started
      when_i_complete_the_procedure
      then_i_should_see_an_enabled_datepicker_with_the_current_date
    end

    context 'and changes the completed date' do
      scenario 'and sees the new completed date' do
        given_i_am_viewing_a_completed_procedure
        when_i_edit_the_completed_date
        then_i_should_see_the_completed_date_has_been_updated
      end
    end
  end

  context 'which is complete and sets it to incomplete' do
    scenario 'and sees date completed disabled' do
      given_i_am_viewing_a_completed_procedure
      when_i_incomplete_the_procedure
      then_i_should_see_a_disabled_datepicker
    end
  end

  def given_i_am_viewing_an_appointment
    next_day               = Time.now.day + 1
    edited_completed_date = Time.now.strftime("%m/#{next_day}/%Y")

    @protocol     = create_and_assign_protocol_to_me
    @protocols_participant  = @protocol.protocols_participants.first
    service      = @protocol.organization.inclusive_child_services(:per_participant).first
    @pricing_map   = create(:pricing_map, service: service, effective_date: @the_middle_of_next_month)

    visit calendar_protocol_participant_path(id: @protocols_participant.id, protocol_id: @protocol)
    wait_for_ajax
  end

  def given_i_am_viewing_a_procedure
    given_i_am_viewing_an_appointment
    when_i_add_a_procedure
  end

  def given_i_am_viewing_a_completed_procedure
    given_i_am_viewing_a_procedure
    given_an_appointment_has_started
    when_i_complete_the_procedure
  end

  def given_an_appointment_has_started
    find('a.start-appointment').click
    wait_for_ajax
  end

  def when_i_complete_the_procedure
    find("div#procedure#{@procedure.id}StatusButtons button.complete-btn").click
    wait_for_ajax
  end

  def when_i_incomplete_the_procedure
    reason = Procedure::NOTABLE_REASONS.first

    find("div#procedure#{@procedure.id}StatusButtons button.incomplete-btn").click
    wait_for_ajax
    bootstrap_select '#procedure_notes_attributes_0_reason', reason
    fill_in 'Comment', with: 'Test comment'
    find('input.btn[type="submit"]').click
  end

  def when_i_add_a_procedure
    visit_group = @protocols_participant.appointments.first.visit_group
    service     = @protocol.organization.inclusive_child_services(:per_participant).first

    first('a.list-group-item.appointment-link').click
    wait_for_ajax
    
    add_a_procedure(service)

    @procedure = visit_group.appointments.first.procedures.where(service_id: service.id).first
  end

  def when_i_edit_the_completed_date
    @complete_procedure    = Procedure.complete.last
    existing_day           = @complete_procedure.completed_date.strftime("%-d").to_i
    @new_day               = pick_new_date(existing_day)
    @edited_completed_date = Time.now.change(day: @new_day)

    bootstrap_datepicker 'input#procedure_completed_date', day: "#{@new_day}"
    wait_for_ajax
    @complete_procedure.reload
  end

  def then_i_should_see_a_disabled_datepicker
    expect(page).to have_css("input#procedure_completed_date[disabled]")
  end

  def then_i_should_see_an_enabled_datepicker_with_the_current_date
    expected_date = page.evaluate_script %Q{ $('input#procedure_completed_date').val(); }
    expect(expected_date).to eq(Time.now.strftime('%m/%d/%Y'))
  end

  def then_i_should_see_the_completed_date_has_been_updated
    date_on_page = find('#procedure_completed_date').value()

    expect(@complete_procedure.completed_date.strftime('%D')).to eq(@edited_completed_date.strftime('%D'))
    expect(date_on_page).to eq(@edited_completed_date.strftime('%m/%d/%Y'))
  end
end
