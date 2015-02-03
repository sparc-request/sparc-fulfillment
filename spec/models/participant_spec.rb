require 'rails_helper'

RSpec.describe Participant, type: :model do

  it { should belong_to(:protocol) }
  it { should belong_to(:arm) }
  it { should have_many(:appointments) }

  before :each do
    @participant = create(:participant_with_protocol)
  end

  context 'validations' do

    it { should validate_presence_of(:protocol_id) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:mrn) }
    it { should validate_presence_of(:date_of_birth) }
    it { should validate_presence_of(:phone) }
    it { should validate_presence_of(:ethnicity) }
    it { should validate_presence_of(:race) }
    it { should validate_presence_of(:gender) }

    context 'custom validations' do

      it 'should create with no errors' do
        expect(@participant).to be_valid
      end

      it 'should validate date_of_birth format to be valid' do
        expect(build(:participant_with_protocol, date_of_birth: "2014-12-16")).to be_valid
      end

      it 'should validate date_of_birth format to be invalid' do
        expect(build(:participant_with_protocol, date_of_birth: "2014-12")).not_to be_valid
      end

      it 'should validate phone format to be valid' do
        expect(build(:participant_with_protocol, phone: "123-123-1234")).to be_valid
      end

      it 'should validate phone format to be invalid' do
        expect(build(:participant_with_protocol, phone: "123-123-123")).not_to be_valid
      end
    end
  end

  context 'class methods' do

    let!(:protocol)     { create(:protocol) }
    let!(:arm)          { create(:arm, protocol_id: protocol.id) }
    let!(:visit_group1) { create(:visit_group, arm: arm, name: 'Turd', position: 1) }
    let!(:visit_group2) { create(:visit_group, arm: arm, name: 'Ferguson', position: 2) }
    let!(:participant)  { create(:participant, arm: arm, protocol_id: protocol.id) }

    describe '#delete' do

      it 'should not permanently delete the record' do
        participant = create(:participant_with_protocol)

        participant.delete

        expect(participant.persisted?).to be
      end
    end

    describe 'callbacks' do

      it 'should callback :update_via_faye after save' do
        participant = create(:participant_with_protocol)

        expect(participant).to callback(:update_via_faye).after(:save)
      end
    end

    describe 'build appointments' do

      it 'should build out appointments based on existing visit groups on initial patient calendar load' do
        participant.build_appointments
        expect(participant.appointments.count).to eq(2)
        expect(participant.appointments[0].name).to eq('Turd')
        expect(participant.appointments[1].position).to eq(2)
      end

      it 'should create additional appointments if a visit group is added to the arm' do
        participant.build_appointments 
        create(:visit_group, arm: participant.arm, name: "Dirk", position: 3)
        arm.reload
        participant.build_appointments
        expect(participant.appointments.count).to eq(3)
        expect(participant.appointments[2].position).to eq(3)
      end

      it 'should not do anything if there are no new visit groups' do
        participant.build_appointments 
        participant.build_appointments 
        expect(participant.appointments.count).to eq(2)
      end
    end
  end
end
