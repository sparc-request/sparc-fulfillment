require 'rails_helper'

RSpec.describe AppointmentHelper do

  describe "#historical_statuses" do
    it "should return old statuses" do
      arm = create(:arm)
      protocol = create_and_assign_protocol_to_me
      participant = create(:participant, arm: arm, protocol: protocol)
      appointment = create(:appointment, name: "Test Appt", participant: participant, arm: arm)
      statuses = appointment.appointment_statuses.map{|x| x.status}
      expect(helper.historical_statuses(statuses)).to eq(statuses - Appointment::STATUSES)
    end
  end
end
