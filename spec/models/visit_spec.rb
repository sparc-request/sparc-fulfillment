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

RSpec.describe Visit, type: :model do

  it { is_expected.to belong_to(:line_item) }
  it { is_expected.to belong_to(:visit_group) }

  it { is_expected.to have_many(:procedures) }


  it { is_expected.to validate_numericality_of(:research_billing_qty).is_greater_than_or_equal_to(0) }
  it { is_expected.to validate_numericality_of(:insurance_billing_qty).is_greater_than_or_equal_to(0) }
  it { is_expected.to validate_numericality_of(:effort_billing_qty).is_greater_than_or_equal_to(0) }

  context 'class methods' do

    describe '#destroy' do

      it 'should destroy associated incomplete Procedures' do
        visit = create(:visit_with_complete_and_incomplete_procedures)

        visit.destroy

        expect(visit.procedures.count).to eq(6)
        expect(visit.procedures.complete.count).to eq(3)
        expect(visit.procedures.untouched.count).to eq(0)
      end

      it 'should not destroy Procedures belonging to begun Appointments' do
        protocol = create(:protocol)
        arm = create(:arm_imported_from_sparc, protocol: protocol)
        appointment = arm.visit_groups.first.appointments.first
        appointment.update_attribute(:start_date, Time.now)
        visit = arm.visit_groups.first.visits.first
        service = visit.line_item.service
        3.times do
          create(:procedure, visit: visit, billing_type: "research_billing_qty", service_id: service.id, appointment_id: appointment.id)
        end
        visit.destroy
        expect(visit.procedures.count).to eq(3)
      end
    end

    describe '#delete' do

      it 'should not permanently delete the record' do
        visit = create(:visit)

        visit.delete

        expect(visit.persisted?).to be
      end
    end
  end

  context 'instance methods' do

    describe 'has_billing?' do

      context 'billing present' do

        it 'should reutrn: true' do
          visit = create(:visit_with_billing)

          expect(visit.has_billing?).to be
        end
      end

      context 'billing not present' do

        it 'should return: false' do
          visit = create(:visit_without_billing)

          expect(visit.has_billing?).to_not be
        end
      end
    end

    describe '.position' do

      it 'should delegate to VisitGroup' do
        visit_group = create(:visit_group_with_arm, position: 1)
        visit       = create(:visit, visit_group: visit_group)

        expect(visit.position).to eq(1)
      end
    end

    describe 'update procedures' do

      it 'should delete procedures' do
        protocol = create(:protocol)
        arm = create(:arm_imported_from_sparc, protocol: protocol)
        appointment = arm.visit_groups.first.appointments.first
        visit = arm.visit_groups.first.visits.first
        service = visit.line_item.service
        3.times do
          create(:procedure, visit: visit, billing_type: "research_billing_qty", service_id: service.id, appointment_id: appointment.id)
        end
        visit.update_procedures(2, 'research_billing_qty')
        expect(visit.procedures.count).to eq(2)
      end

      it 'should not delete Procedures belonging to started Appointments' do
        protocol = create(:protocol)
        arm = create(:arm_imported_from_sparc, protocol: protocol)
        appointment = arm.visit_groups.first.appointments.first
        appointment.update_attribute(:start_date, Time.now)
        visit = arm.visit_groups.first.visits.first
        service = visit.line_item.service
        3.times do
          create(:procedure, visit: visit, billing_type: "research_billing_qty", service_id: service.id, appointment_id: appointment.id)
        end
        visit.update_procedures(0, 'research_billing_qty')
        expect(visit.procedures.count).to eq(3)
      end

      it 'should create procedures' do
        protocol = create(:protocol)
        arm = create(:arm_imported_from_sparc, protocol: protocol)
        appointment = arm.visit_groups.first.appointments.first
        visit = arm.visit_groups.first.visits.first
        service = visit.line_item.service
        3.times do
          create(:procedure, visit: visit, billing_type: "research_billing_qty", service_id: service.id, appointment_id: appointment.id)
        end
        visit.update_procedures(5, 'research_billing_qty')
        expect(visit.procedures.count).to eq(5)
      end
    end
  end
end
