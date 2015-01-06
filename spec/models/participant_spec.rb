require 'rails_helper'

RSpec.describe Participant, type: :model do

  it { should belong_to(:protocol) }
  it { should belong_to(:arm) }

  context 'validations' do

    it { should validate_presence_of(:protocol_id) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:mrn) }
    it { should validate_presence_of(:date_of_birth) }
    it { should validate_presence_of(:address) }
    it { should validate_presence_of(:phone) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:ethnicity) }
    it { should validate_presence_of(:race) }
    it { should validate_presence_of(:gender) }
    it { should validate_presence_of(:gender) }

    context 'custom validations' do

      before { @participant = create(:participant_with_protocol) }

      it 'should create with no errors' do
        expect(@participant).to be_valid
      end

      it 'should validate date_of_birth format to be valid' do
        expect(
          build(:participant_with_protocol, date_of_birth: "2014-12-16")
          ).to be_valid
      end

      it 'should validate date_of_birth format to be invalid' do
        expect(
          build(:participant_with_protocol, date_of_birth: "2014-12")
          ).not_to be_valid
      end

      it 'should validate phone format to be valid' do
        expect(
          build(:participant_with_protocol, phone: "123-123-1234")
          ).to be_valid
      end

      it 'should validate phone format to be invalid' do
        expect(
          build(:participant_with_protocol, phone: "123-123-123")
          ).not_to be_valid
      end
    end
  end

  context 'class methods' do

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
  end
end
