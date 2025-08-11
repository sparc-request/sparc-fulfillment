# Copyright © 2011-2023 MUSC Foundation for Research Development~
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

RSpec.describe Procedure, type: :model do

  it { is_expected.to have_one(:protocol) }
  it { is_expected.to have_one(:arm) }
  it { is_expected.to have_one(:protocols_participant) }

  it { is_expected.to belong_to(:appointment) }
  it { is_expected.to belong_to(:visit) }
  it { is_expected.to belong_to(:core) }

  it { is_expected.to have_many(:notes) }
  it { is_expected.to have_many(:tasks) }

  it { is_expected.to accept_nested_attributes_for(:notes) }

  it { is_expected.to validate_inclusion_of(:status).in_array(Procedure::STATUS_TYPES) }

  context 'class methods' do

    before :each do
      @service              = create(:service)
      protocol              = create(:protocol)
      sub_service_request   = create(:sub_service_request, protocol: protocol)
      participant           = create(:participant)
      arm                   = create(:arm, protocol: protocol)
      protocols_participant = create(:protocols_participant, arm: arm, protocol: protocol, participant: participant)
      @appointment          = create(:appointment, arm: arm, protocols_participant: protocols_participant, name: "Super Arm", protocol: protocol)
    end

    describe '.filter_unavailable_services' do
      let!(:active_service) { create(:service, is_available: true) }
      let!(:inactive_service) { create(:service, is_available: false) }
      let!(:exempt_inactive_service) { create(:service, is_available: false) }
      let!(:unstarted_proc_active_service) { create(:procedure, status: 'unstarted', service: active_service) }
      let!(:unstarted_proc_inactive_service) { create(:procedure, status: 'unstarted', service: inactive_service) }
      let!(:unstarted_proc_exempt_service) { create(:procedure, status: 'unstarted', service: exempt_inactive_service) }
      let!(:incomplete_proc_inactive_service) { create(:procedure, status: 'incomplete', service: inactive_service) }
      let!(:all_procedures) do
        [unstarted_proc_active_service, unstarted_proc_inactive_service, incomplete_proc_inactive_service, unstarted_proc_exempt_service]
      end

      context 'with no exempt services' do
        before do
          allow(Sparc::Setting).to receive(:get_value).with('exempt_inactive_services').and_return([])
        end

        it 'shows only procedures with active services or non-unstarted procedures with inactive services' do
          filtered_procedures = Procedure.filter_unavailable_services(all_procedures)
          expect(filtered_procedures).to eq([unstarted_proc_active_service, incomplete_proc_inactive_service])
        end
      end

      context 'with exempt services' do
        before do
          allow(Sparc::Setting).to receive(:get_value).with('exempt_inactive_services').and_return([exempt_inactive_service.id])
        end

        it 'shows procedures with active services, non-unstarted procedures with inactive services or procedures with inactive services that are exempt' do
          filtered_procedures = Procedure.filter_unavailable_services(all_procedures)
          expect(filtered_procedures).to match_array([unstarted_proc_active_service, unstarted_proc_exempt_service, incomplete_proc_inactive_service])
        end
      end
    end


    describe '.filter_unavailable_services' do
      let!(:active_service) { create(:service, is_available: true) }
      let!(:inactive_service) { create(:service, is_available: false) }
      let!(:exempt_inactive_service) { create(:service, is_available: false) }
      let!(:unstarted_proc_active_service) { create(:procedure, status: 'unstarted', service: active_service) }
      let!(:unstarted_proc_inactive_service) { create(:procedure, status: 'unstarted', service: inactive_service) }
      let!(:unstarted_proc_exempt_service) { create(:procedure, status: 'unstarted', service: exempt_inactive_service) }
      let!(:incomplete_proc_inactive_service) { create(:procedure, status: 'incomplete', service: inactive_service) }
      let!(:all_procedures) do
        [
          unstarted_proc_active_service,
          unstarted_proc_inactive_service,
          unstarted_proc_exempt_service,
          incomplete_proc_inactive_service
        ]
      end

      context 'with no exempt services' do
        before do
          allow(Sparc::Setting).to receive(:get_value).with('exempt_inactive_services').and_return([])
        end

        it 'shows only procedures with active services or non-unstarted status' do
          filtered_procedures = Procedure.filter_unavailable_services(all_procedures)
          expect(filtered_procedures).to eq([unstarted_proc_active_service, incomplete_proc_inactive_service])
        end
      end

      context 'with exempt services' do
        before do
          allow(Sparc::Setting).to receive(:get_value).with('exempt_inactive_services').and_return([exempt_inactive_service.id])
        end

        it 'shows procedures with active services, non-unstarted status, or exempt service IDs' do
          filtered_procedures = Procedure.filter_unavailable_services(all_procedures)
          expect(filtered_procedures).to match_array([
            unstarted_proc_active_service,
            unstarted_proc_exempt_service,
            incomplete_proc_inactive_service
          ])
        end
      end
    end

    describe 'service_name' do

      before(:each) do
        @procedure = create(:procedure, service: @service, appointment: @appointment)
      end

      it "should be equal to the service's name when the procedure is unstarted" do
        name = @service.name + '_'
        @service.update(name: @service.name + '_')
        expect(@procedure.service_name).to eq(name)
      end

      it "should be equal to the service's name at the time the procedure status changes from unstarted" do
        name = @service.name
        @procedure.update(status: 'complete')
        @service.update(name: @service.name + '_')
        expect(@procedure.service_name).to eq(name)
      end
    end

    describe '#delete' do

      it 'should not permanently delete the record' do
        procedure = create(:procedure)

        procedure.delete

        expect(procedure.reload.persisted?).to be
      end

      it 'should destroy the record if the status is unstarted' do
        count_before_test = Procedure.count
        procedure = create(:procedure)

        procedure.destroy

        expect(Procedure.count).to eq(count_before_test)
      end

      it 'should not destroy the record if the status is not unstarted' do
        (Procedure::STATUS_TYPES - ['unstarted']).each do |status|
          procedure = create(:procedure, status.to_sym)

          expect { procedure.destroy }.to raise_error(ActiveRecord::ActiveRecordError)
        end
      end
    end

    describe '.set_save_dependencies' do

      context 'status changed to complete' do

        before do
          to_status = 'complete'
          @procedures = (Procedure::STATUS_TYPES - [to_status]).map do |from_status|
            procedure = create(:procedure, from_status.to_sym)
            procedure.update(service_id: @service.id, status: to_status, appointment: @appointment)
            procedure # may not be necessary
          end
        end

        it 'should remove the incompleted date' do
          expect(@procedures.map(&:incompleted_date)).to_not be_any
        end

        it 'should set the completed date to today' do
          expect(@procedures.map(&:completed_date)).to be_all { |date| date == Date.today.at_midnight }
        end

        it 'should leave status set to complete' do
          expect(@procedures.map(&:status)).to be_all { |status| status == 'complete' }
        end
      end

      context 'status changed to incomplete' do

        before do
          to_status = 'incomplete'
          @procedures = (Procedure::STATUS_TYPES - [to_status]).map do |from_status|
            procedure = create(:procedure, from_status.to_sym)
            procedure.update(service_id: @service.id, status: to_status, appointment: @appointment)
            procedure # may not be necessary
          end
        end

        it 'should set the incompleted date to today' do
          expect(@procedures.map(&:incompleted_date)).to be_all { |date| date == Date.today.at_midnight }
        end

        it 'should remove the completed date' do
          expect(@procedures.map(&:completed_date)).to_not be_any
        end

        it 'should leave status set to incomplete' do
          expect(@procedures.map(&:status)).to be_all { |status| status == 'incomplete' }
        end
      end

      context 'status without task changed to unstarted or follow_up' do

        before do
          to_statuses = ['unstarted', 'follow_up']
          from_statuses = Procedure::STATUS_TYPES - to_statuses
          @procedures = from_statuses.product(to_statuses).map do |from_status, to_status|
            procedure = create(:procedure, from_status.to_sym)
            procedure.update(service_id: @service.id, status: to_status, appointment: @appointment)
            procedure
          end
        end

        it 'should remove completed dates' do
          expect(@procedures.map(&:completed_date)).to_not be_any
        end

        it 'should remove incompleted date' do
          expect(@procedures.map(&:incompleted_date)).to_not be_any
        end
      end

      context 'procedure has a task assigned to it' do

        before do
          to_statuses = ['unstarted', 'follow_up']
          from_statuses = Procedure::STATUS_TYPES - to_statuses

          @procedures = from_statuses.product(to_statuses).map do |from_status, to_status|
            procedure = create(:procedure, from_status.to_sym, :with_task)
            procedure.update(service_id: @service.id, status: to_status, appointment: @appointment)
            procedure
          end
        end

        it 'should remove completed date' do
          expect(@procedures.map(&:completed_date)).to_not be_any
        end

        it 'should remove incompleted date' do
          expect(@procedures.map(&:completed_date)).to_not be_any
        end

        it 'should set status to follow_up' do
          expect(@procedures.map(&:status)).to be_all { |status| status == 'follow_up' }
        end
      end
    end
  end
end
