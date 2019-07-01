# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

RSpec.describe Participant, type: :model do

  before :each do
    @participant = create(:participant)
  end

  context 'validations' do

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
        expect(build(:participant, phone: "123-123-1234")).to be_valid
      end

      it 'should validate phone format to be invalid' do
        expect(build(:participant, phone: "123-123-123")).not_to be_valid
      end

      it 'should validate middle initial format to be valid' do
        expect(build(:participant, middle_initial: "A")).to be_valid
      end

      it 'should validate middle initial format to be invalid' do
        expect(build(:participant, middle_initial: "1a")).not_to be_valid
      end

      it 'should validate zipcode format to be valid' do
        expect(build(:participant, zipcode: "29485")).to be_valid
      end

      it 'should validate zipcode format to be invalid' do
        expect(build(:participant, zipcode: "1234")).not_to be_valid
      end
    end
  end

  context 'class methods' do

    describe "date_of_birth formatting" do
      it "should change the format to a datetime object friendly format" do
        participant = create(:participant)

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
        participant = create(:participant)

        participant.delete

        expect(participant.persisted?).to be
      end
    end

    describe 'full_name' do

      it 'should return the full name of the participant' do
        participant = create(:participant)
        expect(participant.full_name).to eq(participant.first_name + ' ' + participant.middle_initial + ' ' + participant.last_name)
      end
    end
  end
end
