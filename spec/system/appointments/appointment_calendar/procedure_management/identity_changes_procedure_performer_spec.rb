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

feature 'User changes performer of a procedure', js: true do

  scenario 'and sees a note indicating the performer was changed' do
    given_i_have_added_a_procedure_to_an_appointment
    when_i_select_another_name_in_the_performed_by_dropdown
    when_i_view_the_notes
    then_i_should_see_a_note_indicating_that_the_performer_was_changed
  end

  def given_i_have_added_a_procedure_to_an_appointment
    protocol    = create_and_assign_protocol_to_me
    @performer  = create(:identity)
    ClinicalProvider.create(identity: @performer, organization: protocol.organization)
    protocols_participant = protocol.protocols_participants.first
    visit_group = protocols_participant.appointments.first.visit_group
    service     = protocol.organization.inclusive_child_services(:per_participant).first

    visit calendar_protocol_participant_path(id: protocols_participant.id, protocol_id: protocol)
    
    expect(page).to have_css('a.list-group-item.appointment-link', wait: 10)
    first('a.list-group-item.appointment-link').click
    
    expect(page).to have_css('a.btn.start-appointment', visible: :all, wait: 15)
    
    add_a_procedure(service)

    find('a.btn.start-appointment').click
    expect(page).to have_css('a.btn.reset-appointment', visible: true, wait: 10)

    visit_group.appointments.first.procedures.reload
    @procedure = visit_group.appointments.first.procedures.where(service_id: service.id).first
  end

  def when_i_select_another_name_in_the_performed_by_dropdown
    if page.has_css?('tr.info.groupBy', wait: 2)
      group_header = find('tr.info.groupBy', match: :first)
      group_header.click if group_header[:class].include?('expanded')
      expect(page).to have_css('tr.info.groupBy.collapsed', wait: 10)
    end

    # Bypass the global bootstrap_select helper because of the AJAX DOM swap.
    wrapper = find('td.performer div.bootstrap-select', visible: :all, match: :first)
    within(wrapper) do
      find('.dropdown-toggle').click
      
      expect(page).to have_css('ul.dropdown-menu.inner.show', wait: 5)
      
      find('ul.dropdown-menu li a span.text', text: @performer.full_name, visible: :all, match: :first).click
    end
    
    expect(page).to have_css('td.performer div.bootstrap-select .filter-option-inner-inner', text: @performer.full_name, visible: :all, wait: 15)
  end

  def when_i_view_the_notes
    expect(page).to have_css("div#procedure#{@procedure.id}Notes", visible: :all, wait: 10)
    find("div#procedure#{@procedure.id}Notes").click
    
    expect(page).to have_css('.modal-dialog', wait: 10)
  end

  def then_i_should_see_a_note_indicating_that_the_performer_was_changed
    expect(page).to have_css('.note-body', text: "Performer changed to #{@performer.full_name}", wait: 10)
  end
end
