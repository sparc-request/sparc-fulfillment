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
    next_month               = Time.current.month + 1
    @the_middle_of_next_month = Date.current.strftime("0#{next_month}/15/%Y")

    @protocol     = create_and_assign_protocol_to_me
    @participant  = @protocol.participants.first
    service      = @protocol.organization.inclusive_child_services(:per_participant).first
    @pricing_map   = create(:pricing_map, service: service, effective_date: @the_middle_of_next_month)

    visit participant_path(@participant)
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
    find('button.start_visit').click
  end

  def when_i_complete_the_procedure
    find('label.status.complete').click
    wait_for_ajax
  end

  def when_i_incomplete_the_procedure
    reason = Procedure::NOTABLE_REASONS.first

    find('label.status.incomplete').click
    bootstrap_select '.reason-select', reason
    fill_in 'procedure_notes_attributes_0_comment', with: 'Test comment'
    click_button 'Save'
  end

  def when_i_add_a_procedure
    visit_group = @participant.appointments.first.visit_group
    service     = @protocol.organization.inclusive_child_services(:per_participant).first

    bootstrap_select('#appointment_select', visit_group.name)
    wait_for_ajax
    bootstrap_select '#service_list', service.name
    fill_in 'service_quantity', with: '1'
    page.find('button.add_service').click
  end

  def when_i_edit_the_completed_date

    find('.procedures .completed_date_field')
    page.execute_script %Q{ $('.procedures .completed_date_field').trigger('click'); }
    next_month               = Time.current.month + 1
    edited_completed_date = Date.current.strftime("0#{next_month}/15/%Y")
    page.execute_script %Q{ $(".completed-date .completed_date_field").val('#{edited_completed_date}') }
    wait_for_ajax
  end

  def then_i_should_see_a_disabled_datepicker
    expect(page).to have_css(".completed-date input[disabled]")
  end

  def then_i_should_see_an_enabled_datepicker_with_the_current_date
    expected_date = page.evaluate_script %Q{ $('.completed_date_field').first().val(); }
    expect(expected_date).to eq(DateTime.current.strftime('%m/%d/%Y'))
  end

  def then_i_should_see_the_completed_date_has_been_updated
    expected_date = page.evaluate_script %Q{ $('.completed_date_field').first().val(); }
    expect(expected_date).to eq(@the_middle_of_next_month)
  end
end
