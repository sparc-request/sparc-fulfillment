require 'rails_helper'

feature 'Identity incompletes all Services', js: true do

  let!(:protocol)    { create_and_assign_protocol_to_me }
  let!(:participant) { Participant.first }
  let!(:appointment) { Appointment.first }
  let!(:services)    { protocol.organization.inclusive_child_services(:per_participant) }

  context 'in a Core' do

    scenario 'and sees that all selected Services are incompleted' do

    end
  end

  context 'in a Group' do

    scenario 'and sees that all selected Services are incompleted' do

    end
  end
end
