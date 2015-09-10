require 'rails_helper'

feature 'Identity changes a Service', js: true do

  let!(:protocol)    { create_and_assign_protocol_to_me }
  let!(:participant) { Participant.first }
  let!(:appointment) { Appointment.first }
  let!(:services)    { protocol.organization.inclusive_child_services(:per_participant) }

  scenario 'and sees it join an existing group' do
    given_i_am_viewing_a_visit
  end

  scenario 'and sees it leave its original group' do
    given_i_am_viewing_a_visit
  end

  scenario 'and no longer sees the empty original group' do
    given_i_am_viewing_a_visit
  end

  scenario 'and sees the Service is a member of a new group' do
    given_i_am_viewing_a_visit
  end

  scenario 'and sees the Service counter of the joined group has been incremented' do
    given_i_am_viewing_a_visit
  end

  scenario 'and sees the Service counter of the original group has been decremented' do
    given_i_am_viewing_a_visit
  end
end
