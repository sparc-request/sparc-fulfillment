require 'rails_helper'

RSpec.describe Participant, type: :model do

  it { should belong_to(:protocol) }

  describe 'validations' do
    let!(:protocol1)     { create(:protocol) }

    it 'should create with no errors' do
      expect(
        create(:participant, protocol_id: protocol1.id)
        ).to be_valid
    end
    it 'should validate protocol_id' do
      expect(
        build(:participant, protocol_id: "")
        ).not_to be_valid
    end
    it 'should validate first_name' do
      expect(
        build(:participant, protocol_id: protocol1.id, first_name: "")
        ).not_to be_valid
    end
    it 'should validate last_name' do
      expect(
        build(:participant, protocol_id: protocol1.id, last_name: "")
        ).not_to be_valid
    end
    it 'should validate mrn' do
      expect(
        build(:participant, protocol_id: protocol1.id, mrn: "")
        ).not_to be_valid
    end
    it 'should validate status' do
      expect(
        build(:participant, protocol_id: protocol1.id, status: "")
        ).not_to be_valid
    end
    it 'should validate date_of_birth' do
      expect(
        build(:participant, protocol_id: protocol1.id, date_of_birth: "")
        ).not_to be_valid
    end
    it 'should validate date_of_birth format to be valid' do
      expect(
        build(:participant, protocol_id: protocol1.id, date_of_birth: "2014-12-16")
        ).to be_valid
    end
    it 'should validate date_of_birth format to be invalid' do
      expect(
        build(:participant, protocol_id: protocol1.id, date_of_birth: "2014-12")
        ).not_to be_valid
    end
    it 'should validate gender' do
      expect(
        build(:participant, protocol_id: protocol1.id, gender: "")
        ).not_to be_valid
    end
    it 'should validate ethnicity' do
      expect(
        build(:participant, protocol_id: protocol1.id, ethnicity: "")
        ).not_to be_valid
    end
    it 'should validate race' do
      expect(
        build(:participant, protocol_id: protocol1.id, race: "")
        ).not_to be_valid
    end
    it 'should validate address' do
      expect(
        build(:participant, protocol_id: protocol1.id, address: "")
        ).not_to be_valid
    end
    it 'should validate phone' do
      expect(
        build(:participant, protocol_id: protocol1.id, phone: "")
        ).not_to be_valid
    end
    it 'should validate phone format to be valid' do
      expect(
        build(:participant, protocol_id: protocol1.id, phone: "123-123-1234")
        ).to be_valid
    end
    it 'should validate phone format to be invalid' do
      expect(
        build(:participant, protocol_id: protocol1.id, phone: "123-123-123")
        ).not_to be_valid
    end
  end
end
