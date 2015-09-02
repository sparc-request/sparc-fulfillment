require 'rails_helper'

RSpec.describe ParticipantHelper do

  describe "#appointments_for_select" do
    it "should return appointments on the arm" do
      protocol = create_and_assign_protocol_to_me
      arm = protocol.arms.last
      participant = create(:participant, protocol: protocol, arm: arm)

      2.times do
        create(:appointment, participant: participant, arm: arm, name: "Appt")
        create(:appointment, participant: participant, arm: protocol.arms.first, name: "Bad Appt")
      end

      array = [participant.appointments[0], participant.appointments[2]]

      expect(helper.appointments_for_select(arm, participant)).to eq(array)
    end
  end

  describe "#phoneNumberFormatter" do
    it "should return a formatted phone number if in the form ##########" do
      protocol = create_and_assign_protocol_to_me
      participant = protocol.arms.first.participants.first
      
      good_phone = "123-123-1234"
      bad_phone  = "5555555555"

      participant.update_attributes(phone: good_phone)
      expect(helper.phoneNumberFormatter(participant)).to eq(good_phone)

      participant.update_attributes(phone: bad_phone)
      expect(helper.phoneNumberFormatter(participant)).to eq("555-555-5555")
    end
  end
end
