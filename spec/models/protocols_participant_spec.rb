# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

RSpec.describe ProtocolsParticipant, type: :model do

  it { is_expected.to belong_to(:protocol) }
  it { is_expected.to belong_to(:participant) }
  it { is_expected.to belong_to(:arm) }

  it { is_expected.to have_many(:appointments) }

  before :each do
    @protocol = create(:protocol) 
    @participant = create(:participant) 
    @arm = create(:arm, protocol_id: @protocol.id) 
    @protocols_participant = create(:protocols_participant, arm_id: @arm.id, protocol_id: @protocol.id, participant_id: @participant.id) 
  end

  context 'validations' do

    it { is_expected.to validate_presence_of(:protocol_id) }
    it { is_expected.to validate_presence_of(:participant_id) }
  end

  context 'class methods' do

    let!(:protocol)     { create(:protocol) }
    let!(:participant)  { create(:participant) }
    let!(:arm)          { create(:arm, protocol_id: protocol.id) }
    let!(:visit_group1) { create(:visit_group, arm: arm, name: 'Turd') }
    let!(:visit_group2) { create(:visit_group, arm: arm, name: 'Ferguson') }
    let!(:protocols_participant)  { create(:protocols_participant, arm: arm, protocol: protocol, participant: participant) }


    describe 'update appointments on arm change' do

      it "should set appointments with completed procedures to completed" do
        appts_with_completes = protocols_participant.appointments.map{|a| a.has_completed_procedures}
        protocols_participant.update_appointments_on_arm_change
        expect(protocols_participant.appointments.include?(appts_with_completes))
      end
      it "should delete incomplete appointments" do
        appts_with_completes = protocols_participant.appointments.map{|a| a.has_completed_procedures}
        protocols_participant.update_appointments_on_arm_change
        expect(protocols_participant.appointments.exclude?(appts_with_completes))
      end
    end

    describe 'build appointments' do

      it 'should build out appointments based on existing visit groups on initial patient calendar load' do
        protocols_participant.build_appointments
        expect(protocols_participant.appointments.size).to eq(2)
        expect(protocols_participant.appointments[0].name).to eq('Turd')
        expect(protocols_participant.appointments[1].position).to eq(2)
      end

      it 'should create additional appointments if a visit group is added to the arm' do
        protocols_participant.build_appointments
        create(:visit_group, arm_id: protocols_participant.arm.id, name: "Dirk")
        protocols_participant.arm.reload
        protocols_participant.build_appointments
        expect(protocols_participant.appointments.size).to eq(3)
        expect(protocols_participant.appointments[2].position).to eq(3)
      end

      it 'should not do anything if there are no new visit groups' do
        protocols_participant.build_appointments
        protocols_participant.build_appointments
        expect(protocols_participant.appointments.count).to eq(2)
      end
    end

    describe 'callbacks' do

      it 'should callback :update_via_faye after save' do
        protocols_participant = create(:protocols_participant, arm_id: create(:arm).id, protocol_id: create(:protocol).id, participant_id: create(:participant).id)

        expect(protocols_participant).to callback(:update_faye).after(:save)
      end
    end
  end
end
