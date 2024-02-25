require 'rails_helper'

RSpec.describe ProcedureGroup, type: :model do

  it { is_expected.to belong_to(:appointment) }
  it { is_expected.to validate_presence_of(:appointment)}

  before :each do
    @service = create(:service)
    protocol = create(:protocol)
    sub_service_request = create(:sub_service_request, protocol: protocol)
    participant = create(:participant)
    arm = create(:arm, protocol: protocol)
    protocols_participant = create(:protocols_participant, arm: arm, protocol: protocol, participant: participant)
    @appointment = create(:appointment, arm: arm, protocols_participant: protocols_participant, name: "Super Arm", protocol: protocol)
  end

  describe 'attributes' do
    before(:each) do
      @procedure_group = create(:procedure_group, appointment: @appointment)
    end
    it 'should have a start_time' do
      expect(@procedure_group.start_time).to be
    end

    it 'should have an end_time' do
      expect(@procedure_group.end_time).to be
    end
  end
end
