require 'rails_helper'

RSpec.describe Participant, type: :model do

  it { is_expected.to belong_to(:protocol) }
  it { is_expected.to belong_to(:arm) }

  it { is_expected.to have_many(:appointments) }

  before :each do
    @participant = create(:participant_with_protocol)
  end

  context 'validations' do

    it { is_expected.to validate_presence_of(:protocol_id) }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:mrn) }
    it { is_expected.to validate_presence_of(:date_of_birth) }
    it { is_expected.to validate_presence_of(:ethnicity) }
    it { is_expected.to validate_presence_of(:race) }
    it { is_expected.to validate_presence_of(:gender) }
    it { is_expected.to validate_presence_of(:address) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_presence_of(:zipcode) }

    context 'custom validations' do

      it 'should create with no errors' do
        expect(@participant).to be_valid
      end

      it 'should validate phone format to be valid' do
        expect(build(:participant_with_protocol, phone: "123-123-1234")).to be_valid
      end

      it 'should validate phone format to be invalid' do
        expect(build(:participant_with_protocol, phone: "123-123-123")).not_to be_valid
      end

      it 'should validate middle initial format to be valid' do
        expect(build(:participant_with_protocol, middle_initial: "A")).to be_valid
      end

      it 'should validate middle initial format to be invalid' do
        expect(build(:participant_with_protocol, middle_initial: "1a")).not_to be_valid
      end

      it 'should validate zipcode format to be valid' do
        expect(build(:participant_with_protocol, zipcode: "29485")).to be_valid
      end

      it 'should validate zipcode format to be invalid' do
        expect(build(:participant_with_protocol, zipcode: "1234")).not_to be_valid
      end
    end
  end

  context 'class methods' do

    let!(:protocol)     { create(:protocol) }
    let!(:arm)          { create(:arm, protocol_id: protocol.id) }
    let!(:visit_group1) { create(:visit_group, arm: arm, name: 'Turd') }
    let!(:visit_group2) { create(:visit_group, arm: arm, name: 'Ferguson') }
    let!(:participant)  { create(:participant, arm: arm, protocol_id: protocol.id) }

    describe "date_of_birth formatting" do
      it "should change the format to a datetime object friendly format" do
        participant = create(:participant_with_protocol)

        expect(participant.date_of_birth).to be
      end

      it "should fail the validation if date_of_birth is nil" do
        expect(build(:participant, date_of_birth: nil)).not_to be_valid
      end

      it "should fail the validation if the date_of_birth is empty" do
        expect(build(:participant, date_of_birth: ""))
      end
    end

    describe '#delete' do

      it 'should not permanently delete the record' do
        participant = create(:participant_with_protocol)

        participant.delete

        expect(participant.persisted?).to be
      end
    end

    describe 'full_name' do

      it 'should return the full name of the participant' do
        participant = create(:participant_with_protocol)
        expect(participant.full_name).to eq(participant.first_name + ' ' + participant.middle_initial + ' ' + participant.last_name)
      end
    end

    describe 'callbacks' do

      it 'should callback :update_via_faye after save' do
        participant = create(:participant_with_protocol)

        expect(participant).to callback(:update_faye).after(:save)
      end
    end

    describe 'update appointments on arm change' do

      it "should set appointments with completed procedures to completed" do
        appts_with_completes = participant.appointments.map{|a| a.has_completed_procedures}
        participant.update_appointments_on_arm_change
        expect(participant.appointments.include?(appts_with_completes))
      end
      it "should delete incomplete appointments" do
        appts_with_completes = participant.appointments.map{|a| a.has_completed_procedures}
        participant.update_appointments_on_arm_change
        expect(participant.appointments.exclude?(appts_with_completes))
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
        create(:visit_group, arm: participant.arm, name: "Dirk")
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
