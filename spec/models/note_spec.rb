require 'rails_helper'

RSpec.describe Note, type: :model do

  it { is_expected.to belong_to(:notable) }
  it { is_expected.to belong_to(:identity) }

  it { is_expected.to validate_inclusion_of(:kind).in_array(Note::KIND_TYPES) }

  describe 'reason validations' do

    it 'should require a reason if notable type is Procedure and kind is reason' do
      procedure = create(:procedure)
      note      = build(:note_reason, notable: procedure, reason: '')
      expect(note).to_not be_valid
    end
  end

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
        note      = create(:note_reason, notable: procedure, comment: 'Test comment', reason: Procedure::NOTABLE_REASONS.first)

        expect(note.comment).to eq("#{Procedure::NOTABLE_REASONS.first}: Test comment")
      end
    end

    context 'followup' do

      it 'should return a formatted comment' do
        procedure = create(:procedure)
        task      = create(:task, assignable_type: "Procedure", assignable_id: procedure.id, due_at: "01-01-2015")
        note      = create(:note_followup, notable: procedure, comment: 'Test comment')

        expect(note.comment).to eq('Followup: 2015-01-01: Test comment')
      end
    end
  end
end
