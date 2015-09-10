require 'rails_helper'

feature 'Identity adds multiple Services', js: true do

  let!(:protocol)    { create_and_assign_protocol_to_me }
  let!(:participant) { Participant.first }
  let!(:appointment) { Appointment.first }
  let!(:services)    { protocol.organization.inclusive_child_services(:per_participant) }

  scenario 'which are not part of an existing group' do
    given_i_am_viewing_a_visit
  end

  scenario 'which are part of an existing Service group' do
    given_i_am_viewing_a_visit
  end
end
