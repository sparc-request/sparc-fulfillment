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

feature 'User views Participant', js: true do

  scenario 'and does not have access' do
    given_i_do_not_have_access_to_a_protocol
    when_i_view_a_participants_calendar
    then_i_should_be_redirected_to_the_home_page
  end

  scenario 'and sees the Participants attributes in the header' do
    given_i_have_access_to_a_protocol
    when_i_view_a_participants_calendar
    then_i_should_see_the_participant_calendar
  end

  scenario 'and sees a list of Visits ordered by :completed_date' do
    given_i_have_access_to_a_protocol_with_appointments
    when_i_view_a_participants_calendar
    then_i_should_see_an_ordered_list_of_visits
  end

  def given_i_do_not_have_access_to_a_protocol
    @protocol    = create(:protocol_imported_from_sparc)
    @participant = @protocol.participants.first
  end

  def given_i_have_access_to_a_protocol
    @protocol     = create_and_assign_protocol_to_me
    @participant  = @protocol.participants.first
  end

  def given_i_have_access_to_a_protocol_with_appointments
    protocol      = create_and_assign_protocol_to_me
    @participant  = create(:participant_with_completed_appointments,
                            protocol: protocol,
                            arm: protocol.arms.first)
    @appointments = @participant.appointments
  end

  def when_i_view_a_participants_calendar
    visit participant_path @participant
    wait_for_ajax
  end

  def then_i_should_be_redirected_to_the_home_page
    expect(current_path).to eq root_path # gets redirected back to index
  end

  def then_i_should_see_the_participant_calendar
    expect(page).to have_css('#participant-info')
    expect(page).to have_content(@participant.full_name)
    expect(page).to have_content(@participant.mrn) unless @participant.mrn.blank?
    expect(page).to have_content(@participant.external_id) unless @participant.external_id.blank?
    expect(page).to have_content(@participant.arm.name) unless @participant.arm.blank?
    expect(page).to have_content(@participant.status)
    expect(page).to have_content(@protocol.id)
  end

  def then_i_should_see_an_ordered_list_of_visits
    @appointments.sort_by { |appointment| appointment.completed_date }.reverse.each_with_index do |appointment, index|
      expect(page).to have_css("table.visits tbody tr:nth-of-type(#{index + 1})", text: appointment.name)
    end
  end
end
