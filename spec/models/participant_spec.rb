require 'rails_helper'

RSpec.describe Participant, type: :model do

  it { should belong_to(:protocol) }

  describe 'validations' do
    let!(:protocol)     {create(:protocol)}
    let!(:participant)  {create(:participant, protocol_id: protocol.id)}
    it 'should create with no errors' do
      expect(participant).to be_valid
    end
    it 'should validate protocol_id' do
      participant.protocol_id = ""
      expect(participant).not_to be_valid
    end
    it 'should validate first_name' do
      participant.update_attribute(:first_name, "")
      expect(participant).not_to be_valid
    end
    it 'should validate last_name' do
      participant.update_attribute(:last_name, "")
      expect(participant).not_to be_valid
    end
    it 'should validate mrn' do
      participant.update_attribute(:mrn, "")
      expect(participant).not_to be_valid
    end
    it 'should validate status' do
      participant.update_attribute(:status, "")
      expect(participant).not_to be_valid
    end
    it 'should validate date_of_birth' do
      participant.update_attribute(:date_of_birth, "")
      expect(participant).not_to be_valid
    end
    it 'should validate date_of_birth format to be valid' do
      participant.update_attribute(:date_of_birth, "2014-04-12")
      expect(participant).to be_valid
    end
    it 'should validate date_of_birth format to be invalid' do
      participant.update_attribute(:date_of_birth, "2014-04")
      expect(participant).not_to be_valid
    end
    it 'should validate gender' do
      participant.update_attribute(:gender, "")
      expect(participant).not_to be_valid
    end
    it 'should validate ethnicity' do
      participant.update_attribute(:ethnicity, "")
      expect(participant).not_to be_valid
    end
    it 'should validate race' do
      participant.update_attribute(:race, "")
      expect(participant).not_to be_valid
    end
    it 'should validate address' do
      participant.update_attribute(:address, "")
      expect(participant).not_to be_valid
    end
    it 'should validate phone' do
      participant.update_attribute(:phone, "")
      expect(participant).not_to be_valid
    end
    it 'should validate phone format to be valid' do
      participant.update_attribute(:phone, "123-343-5519")
      expect(participant).to be_valid
    end
    it 'should validate phone format to be invalid' do
      participant.update_attribute(:phone, "123-343-551")
      expect(participant).not_to be_valid
    end
  end
end
