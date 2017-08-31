# Copyright © 2011-2017 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

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
        task      = create(:task, assignable_type: "Procedure", assignable_id: procedure.id, due_at: "01/01/2015")
        note      = create(:note_followup, notable: procedure, comment: 'Test comment')

        expect(note.comment).to eq('Followup: 2015-01-01: Test comment')
      end
    end
  end
end
