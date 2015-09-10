require 'rails_helper'

feature 'Identity removes a Service', js: true do

  let!(:protocol)    { create_and_assign_protocol_to_me }
  let!(:participant) { Participant.first }
  let!(:appointment) { Appointment.first }
  let!(:services)    { protocol.organization.inclusive_child_services(:per_participant) }

  context 'when group has more than 2 members' do

    scenario 'and no longer sees the Service' do
    end

    scenario 'and sees the group counter decremented' do

    end
  end

  context 'when group has 2 members' do

    scenario 'and no longer sees the group' do

    end
  end

  context 'when Core has only 1 Service' do

    scenario 'and no longer sees the Core' do

    end
  end
end
