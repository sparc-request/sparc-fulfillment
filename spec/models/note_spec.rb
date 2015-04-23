require 'rails_helper'

RSpec.describe Note, type: :model do

  it { is_expected.to belong_to(:notable) }
  it { is_expected.to belong_to(:user) }

  it { is_expected.to validate_inclusion_of(:kind).in_array(Note::KIND_TYPES) }

  describe '.comment' do
    context 'validation' do
      
      it 'should validate the reason within the context of the notable type' do
        procedure = create(:procedure)
        note      = create(:note, notable: procedure, comment: 'Test comment')
        expect(note).to validate_inclusion_of(:reason).in_array(Procedure::NOTABLE_REASONS)
      end
    end

    context 'reason' do

      it 'should return a formatted comment' do
        procedure = create(:procedure)
        note      = create(:note, notable: procedure, comment: 'Test comment')

        expect(note.comment).to eq('Test comment')
      end
    end

    context 'followup' do

      it 'should return a formatted comment' do
        Timecop.travel('01/01/2015')

        procedure = create(:procedure, follow_up_date: Time.current)
        note      = create(:note_followup, notable: procedure, comment: 'Test comment')

        expect(note.comment).to eq('Followup: 2015-01-01: Test comment')
      end
    end
  end
end
