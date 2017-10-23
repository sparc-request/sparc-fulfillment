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

RSpec.describe Protocol, type: :model do

  it { is_expected.to belong_to(:sub_service_request) }

  it { is_expected.to have_one(:organization) }
  it { is_expected.to have_one(:human_subjects_info) }

  it { is_expected.to have_many(:arms).dependent(:destroy) }
  it { is_expected.to have_many(:line_items).dependent(:destroy) }
  it { is_expected.to have_many(:participants).dependent(:destroy) }
  it { is_expected.to have_many(:project_roles) }
  it { is_expected.to have_many(:service_requests) }
  it { is_expected.to belong_to(:sub_service_request) }

  context 'class methods' do

    describe ".human_subjects_info" do

      it "should find associated HumanSubjectsInfo by :sparc_id" do
        protocol                      = create(:protocol)
        expected_human_subjects_info  = create(:human_subjects_info, protocol: protocol)
        other_human_subjects_info     = create(:human_subjects_info)

        expect(protocol.human_subjects_info).to eq(expected_human_subjects_info)
      end
    end

    describe '#delete' do

      it 'should not permanently delete the record' do
        protocol = create(:protocol)

        protocol.delete

        expect(protocol.persisted?).to be
      end
    end

    describe 'callbacks' do

      it 'should callback :update_via_faye after save' do
        protocol = create_and_assign_protocol_to_me

        expect(protocol).to callback(:update_faye).after(:save)
      end

      it 'should callback :update_via_faye after destroy' do
        protocol = create_and_assign_protocol_to_me

        expect(protocol).to callback(:update_faye).after(:destroy)
      end
    end
  end

  context 'instance methods' do

    describe 'pi' do

      it 'should return the primary investigator of the protocol' do
        protocol = create_and_assign_protocol_to_me

        expect(protocol.pi).to eq protocol.project_roles.where(role: "primary-pi").first.identity
      end
    end

    describe 'coordinators' do

      it 'should return the coordinators of the protocol' do
        protocol = create_and_assign_protocol_to_me

        expect(protocol.coordinators).to eq protocol.project_roles.where(role: "research-assistant-coordinator").map(&:identity)
      end
    end

    describe 'one_time_fee_line_items' do

      it 'should return the line items of type one time fee of the protocol' do
        protocol = create_and_assign_protocol_to_me

        expect(protocol.one_time_fee_line_items).to eq protocol.line_items.includes(:service).where(:services => {:one_time_fee => true})
      end
    end

    describe 'protocol type' do
      it 'should return the protocol type Study' do
        
        protocol = create(:protocol)
        sparc_protocol = protocol.sparc_protocol
        sparc_protocol.update_attributes(type: 'Study')

        expect(protocol.protocol_type).to eq Sparc::Protocol.where(id: protocol.sparc_id).first.type
      end

       it 'should return the protocol type Project' do
        
        protocol = create(:protocol)
        sparc_protocol = protocol.sparc_protocol
        sparc_protocol.update_attributes(type: 'Project')

        expect(protocol.protocol_type).to eq Sparc::Protocol.where(id: protocol.sparc_id).first.type
      end
    end

    describe 'delegated methods' do

      let!(:protocol)            { create(:protocol) }
      let!(:service_request)     { create(:service_request, protocol: protocol) }
      let!(:user)                { create(:identity)}
      let!(:sub_service_request) { create(:sub_service_request, service_request: service_request, status: 'ctrc_approved') }

      before :each do
        protocol.update_attributes(sub_service_request: sub_service_request)
      end

      context 'status' do

        it 'should get the sub service requests status' do
          expect(protocol.status).to eq('ctrc_approved')
        end
      end

      context 'owner' do

        it 'should get the correct owner from the sub service request' do
          sub_service_request.update_attributes(owner_id: user.id)
          expect(protocol.owner).to eq(sub_service_request.owner)
        end
      end

      context 'service requester' do

        it 'should get the correct requester from the sub service request' do
          sub_service_request.update_attributes(service_requester_id: user.id)
          expect(protocol.service_requester.id).to eq(sub_service_request.service_requester_id)
        end
      end
    end
  end
end
