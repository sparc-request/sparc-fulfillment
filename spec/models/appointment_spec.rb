# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

RSpec.describe Appointment, type: :model do

  it { is_expected.to have_one(:protocol) }

  it { is_expected.to belong_to(:arm) }
  it { is_expected.to belong_to(:visit_group) }
  it { is_expected.to have_many(:procedures) }
  it { is_expected.to have_many(:appointment_statuses) }

  context 'validations' do
    it { is_expected.to validate_presence_of :protocols_participant_id }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :arm_id }
  end

  context 'instance methods' do
    describe 'has_completed_procedures?' do
      before :each do
        protocol = create(:protocol)
        arm = create(:arm, protocol: protocol)
        participant = create(:participant)
        protocols_participant = create(:protocols_participant, arm: arm, protocol: protocol, participant: participant)
        @appt = create(:appointment, arm: arm, name: "Visit 1", protocols_participant: protocols_participant, position: 1)
        @proc1 = create(:procedure, :complete, appointment: @appt)
        @proc2 = create(:procedure, appointment: @appt)
      end

      it 'should return true when appt has completed procedures' do
        expect(@appt.has_completed_procedures?).to be true
      end

      it 'should return false when appt doesnt have completed procedures' do
        @proc1.update_attributes(status: "unstarted")
        expect(@appt.has_completed_procedures?).to be false
      end
    end
  end
end
