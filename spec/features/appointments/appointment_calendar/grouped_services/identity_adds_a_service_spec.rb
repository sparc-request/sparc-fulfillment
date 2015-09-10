require 'rails_helper'

feature 'Identity adds a Service', js: true do

  let!(:protocol)    { create_and_assign_protocol_to_me }
  let!(:participant) { Participant.first }
  let!(:appointment) { Appointment.first }
  let!(:services)    { protocol.organization.inclusive_child_services(:per_participant) }

  scenario 'and sees the service in the correct Core' do
    given_i_am_viewing_a_visit
  end

  scenario 'which is part of an existing group and sees the Service in a group' do
    given_i_am_viewing_a_visit
  end

  scenario 'which is not part of a group and does not see the Service in a group' do
    given_i_am_viewing_a_visit
  end

  scenario 'which is not part of an existing group and sees a Service group created' do
    given_i_am_viewing_a_visit
  end

  scenario 'which is part of an existing group and sees the group counter incremented' do
    given_i_am_viewing_a_visit
  end
end
