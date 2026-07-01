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

RSpec.describe 'User messes with a procedures date completed', type: :system, js: true do
  let(:protocol)              { create_and_assign_protocol_to_me }
  let(:protocols_participant) { protocol.protocols_participants.first }
  let(:service)               { protocol.organization.inclusive_child_services(:per_participant).first }

  # Lazily evaluated: safely queries the DB for the newly created procedure only when needed
  let(:procedure)              { protocols_participant.appointments.first.procedures.find_by(service: service) }

  # Extracted to prevent end-of-month and leap year flakiness natively
  let(:target_date)            { Date.current.beginning_of_month + pick_new_date(Date.current.day).days }

  context 'which is incomplete' do
    scenario 'and sees a disabled datepicker' do
      given_i_am_viewing_a_visit(participant: protocols_participant, protocol: protocol)
      and_i_have_added_a_procedure
      then_i_should_see_a_disabled_datepicker
    end
  end

  context 'which is complete' do
    scenario 'and sees date completed updated and enabled' do
      given_i_am_viewing_a_started_visit(participant: protocols_participant, protocol: protocol)
      and_i_have_added_a_procedure
      when_i_complete_the_procedure
      then_i_should_see_an_enabled_datepicker_with_the_current_date
    end

    context 'and changes the completed date' do
      scenario 'and sees the new completed date' do
        given_i_am_viewing_a_started_visit(participant: protocols_participant, protocol: protocol)
        and_i_have_added_a_procedure
        when_i_complete_the_procedure
        when_i_edit_the_completed_date
        then_i_should_see_the_completed_date_has_been_updated
      end
    end
  end

  context 'which is complete and sets it to incomplete' do
    scenario 'and sees date completed disabled' do
      given_i_am_viewing_a_started_visit(participant: protocols_participant, protocol: protocol)
      and_i_have_added_a_procedure
      when_i_complete_the_procedure
      when_i_incomplete_the_procedure
      then_i_should_see_a_disabled_datepicker
    end
  end

  def and_i_have_added_a_procedure
    add_a_procedure(service: service)
  end

  def when_i_complete_the_procedure
    within("#procedure#{procedure.id}StatusButtons") do
      find('button.complete-btn').click
    end
    
    expect(page).to have_css("#procedure#{procedure.id}StatusButtons button.complete-btn.active")
  end

  def when_i_incomplete_the_procedure
    within("#procedure#{procedure.id}StatusButtons") do
      find('button.incomplete-btn').click
    end
    
    expect(page).to have_css('.modal.show')

    # Dropdown logic kept outside the 'within' block to prevent swallowing body clicks
    find('#procedure_notes_attributes_0_reason', visible: :hidden).ancestor('.bootstrap-select', match: :first).find('.dropdown-toggle').click
    expect(page).to have_css('.dropdown-menu.show')
    find('.dropdown-menu.show span.text', match: :first).click

    fill_in 'Comment', with: 'Test comment'
    
    within('.modal.show') do
      find('input[type="submit"]').click
    end

    expect(page).to have_no_css('.modal.show')
    expect(page).to have_css("#procedure#{procedure.id}StatusButtons button.incomplete-btn.active")
  end

  def when_i_edit_the_completed_date
    # SYNC POINT: Natively wait for the JS to finish enabling the datepicker and injecting the default "today" date. Otherwise, Capybara types too fast and the JS overwrites the custom date.
    within("#procedure#{procedure.id}CompletedDatePicker") do
      expect(page).to have_field('procedure[completed_date]', with: Date.current.strftime('%m/%d/%Y'), disabled: false)
    end

    input = find("#procedure#{procedure.id}CompletedDatePicker input")
    
    # Native Capybara interaction: click to focus, safely backspace out the old date to appease the JS mask, and type the new date natively.
    input.click
    input.set(target_date.strftime('%m/%d/%Y'), clear: :backspace)
    
    # Native blur event
    find('body').click(x: 0, y: 0)
    
    # Native sync point to guarantee the UI processed the input before asserting backend logic
    within("#procedure#{procedure.id}CompletedDatePicker") do
      expect(page).to have_field('procedure[completed_date]', with: target_date.strftime('%m/%d/%Y'))
    end
  end

  def then_i_should_see_a_disabled_datepicker
    within("#procedure#{procedure.id}CompletedDatePicker") do
      expect(page).to have_field('procedure[completed_date]', disabled: true)
    end
  end

  def then_i_should_see_an_enabled_datepicker_with_the_current_date
    within("#procedure#{procedure.id}CompletedDatePicker") do
      # Completely eradicating the page.evaluate_script anti-pattern
      expect(page).to have_field('procedure[completed_date]', with: Date.current.strftime('%m/%d/%Y'), disabled: false)
    end
  end

  def then_i_should_see_the_completed_date_has_been_updated
    within("#procedure#{procedure.id}CompletedDatePicker") do
      expect(page).to have_field('procedure[completed_date]', with: target_date.strftime('%m/%d/%Y'))
    end
  end
end