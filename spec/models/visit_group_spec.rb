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

RSpec.describe VisitGroup, type: :model do

  it { is_expected.to belong_to(:arm) }
  it { is_expected.to have_many(:visits).dependent(:destroy) }
  it { is_expected.to have_many(:line_items).through(:arm) }
  it { is_expected.to have_many(:appointments) }

  context 'validations' do
    it { is_expected.to validate_presence_of :arm_id }
    it { is_expected.to validate_presence_of :name }

    context 'if use epic:' do
      it "sets use_epic to true" do
        ClimateControl.modify USE_EPIC: 'true' do
          is_expected.to validate_presence_of :day
          is_expected.to validate_numericality_of :day
        end
      end
    end

    context 'if not use epic:' do
      it "sets use_epic to false" do
        ClimateControl.modify USE_EPIC: 'false' do
          is_expected.not_to validate_presence_of :day
        end
      end
    end

    context 'if day present' do
      context "insertion results in in-order days" do
        it "should be valid" do
          arm = Arm.create(subject_count: 1, visit_count: 1, name: "Arm1")
          create(:visit_group, position: 1, day: 1, arm: arm)
          create(:visit_group, position: 2, day: 8, arm: arm)

          vg = build(:visit_group, position: 2, day: 2, arm: arm)

          expect(vg).to be_valid
        end
      end

      context "insertion results in out-of-order days" do
        it "should be invalid" do
          arm = Arm.create(subject_count: 1, visit_count: 1, name: "Arm2")
          create(:visit_group, position: 1, day: 1, arm: arm)
          create(:visit_group, position: 2, day: 8, arm: arm)

          vg = build(:visit_group, position: 2, day: 0, arm: arm)

          expect(vg).not_to be_valid
        end
      end

      context "changing position towards the beginning" do
        context "results in in-order days" do
          it "should be valid" do
            arm = Arm.create(subject_count: 1, visit_count: 1, name: "Arm3")
            create(:visit_group, position: 1, day: 1, arm: arm)
            create(:visit_group, position: 2, day: 8, arm: arm)
            vg = build(:visit_group, position: 3, day: 4, arm: arm)
            vg.save(validate: false)

            vg.position = 2

            expect(vg).to be_valid
          end
        end

        context "result in out-of-order days" do
          it "should be invalid" do
            arm = Arm.create(subject_count: 1, visit_count: 1, name: "Arm4")
            create(:visit_group, position: 1, day: 1, arm: arm)
            create(:visit_group, position: 2, day: 8, arm: arm)
            vg = create(:visit_group, position: 3, day: 16, arm: arm)

            vg.position = 2

            expect(vg).not_to be_valid
          end
        end
      end

      context "changing position towards the end" do
        context "results in in-order days" do
          it "should be valid" do
            arm = Arm.create(subject_count: 1, visit_count: 1, name: "Arm5")
            vg = create(:visit_group, position: 1, day: 4, arm: arm)
            build(:visit_group, position: 2, day: 1, arm: arm).save(validate: false)
            build(:visit_group, position: 3, day: 8, arm: arm)
            vg.save(validate: false)

            vg.position = 2

            expect(vg).to be_valid
          end
        end

        context "result in out-of-order days" do
          it "should be invalid" do
            arm = Arm.create(subject_count: 1, visit_count: 1, name: "Arm6")
            vg = create(:visit_group, position: 1, day: 1, arm: arm)
            create(:visit_group, position: 2, day: 8, arm: arm)
            create(:visit_group, position: 3, day: 16, arm: arm)

            vg.position = 2

            expect(vg).not_to be_valid
          end
        end
      end

      context "adding visit as last" do
        context "result in out-of-order days" do
          it "should be invalid" do
            arm = Arm.create(subject_count: 1, visit_count: 1, name: "Arm7")
            create(:visit_group, position: 1, day: 1, arm: arm)
            create(:visit_group, position: 2, day: 8, arm: arm)
            vg = build(:visit_group, position: nil, day: 7, arm: arm)

            expect(vg).not_to be_valid
          end
        end
      end
    end
  end

  context 'class methods' do
    describe '.per_page' do
      it 'should inherit from Visit' do
        expect(VisitGroup.per_page).to eq(Visit.per_page)
      end
    end

    describe '#delete' do
      it 'should not permanently delete the record' do
        visit_group = create(:visit_group_with_arm)

        visit_group.delete

        expect(visit_group.persisted?).to be
      end
    end

    describe 'default_scope' do

      it 'should be scoped to position' do
        DatabaseCleaner[:active_record, model: VisitGroup].clean_with(:truncation)
        groups = []
        # create them with positions 3,2,1
        (3..1).each do |p|
          vg = create(:visit_group_with_arm, position: p)
          groups << vg
        end
        # expect them to return from query in position-order 1,2,3
        sorted_groups = VisitGroup.all
        expect(groups.first).to eq(sorted_groups.last)
        expect(groups.second).to eq(sorted_groups.second)
        expect(groups.third).to eq(sorted_groups.first)
      end
    end

    describe 'private' do
      before :each do
          @protocol = create(:protocol)
          @arm = create(:arm, protocol: @protocol)
          @arm.visit_groups.each{|vg| vg.destroy}
          @arm.reload
          @vg_a        = create(:visit_group, name: 'A', position: 1, day: 2, arm_id: @arm.id)
          @vg_b        = create(:visit_group, name: 'B', position: 2, day: 4, arm_id: @arm.id)
          @vg_c        = create(:visit_group, name: 'C', position: 3, day: 6, arm_id: @arm.id)
          @participant = create(:participant)
          @protocols_participant = create(:protocols_participant, arm: @arm, protocol: @protocol, participant: @participant)
          @procedure   = create(:procedure, :complete, appointment: @protocols_participant.appointments.first)
        end

      after :each do 
        DatabaseCleaner.clean
      end  

      describe 'reorder' do
        it 'should reorder_visit_groups_up' do
          @vg_d = create(:visit_group, name: 'D', position: 3, day: 5, arm_id: @arm.id)
          @vg_c.reload
          expect(@vg_c.position).to eq(4)
        end

        it 'should reorder_visit_groups_down' do
          @vg_d = create(:visit_group, name: 'D', position: 3, day: 5, arm_id: @arm.id)
          @vg_c.reload
          expect(@vg_c.position).to eq(4)

          @vg_d.destroy
          @vg_c.reload
          expect(@vg_c.position).to eq(3)
        end
      end

      describe 'create and update appointments for visit groups' do
        it "should create appointments for subjects on the arm after visit group creation" do
          @vg_e = create(:visit_group, name: 'E', position: nil, day: 10, arm_id: @arm.id)
          @protocols_participant.reload
          expect(@protocols_participant.appointments.last.visit_group_id).to eq(@vg_e.id) 
        end

        it "should update appointment order for subjects after visit group order change" do 
          @vg_c.reload.update(position: 2, day: 3)
          expect(@protocols_participant.reload.appointments.second.name).to eq("C")
        end

        it "should create missing appointments for subjects on creation of new visit group" do 
          @protocols_participant.reload.appointments.third.destroy
          @protocols_participant.reload.appointments.second.destroy
          post_delete_visit_count = @protocols_participant.appointments.count

          @vg_d = create(:visit_group, name: 'D', position: 4, day: 10, arm_id: @arm.id)
          expect(@protocols_participant.reload.appointments.count).to be > post_delete_visit_count
          expect(@protocols_participant.reload.appointments.count).to eq(4) 
        end

        it "should create missing appointments for subjects on update of existing group" do 
          @protocols_participant.reload.appointments.third.destroy
          @protocols_participant.reload.appointments.second.destroy
          post_delete_visit_count = @protocols_participant.appointments.count

          @vg_b.reload.update(name: "temp")
          expect(@protocols_participant.reload.appointments.count).to be > post_delete_visit_count
          expect(@protocols_participant.reload.appointments.count).to eq(3) 
        end

        it "should correctly place appointment for subject despite custom appointment when visit group is created" do 
          @protocols_participant.reload.appointments.create(name: "custom appointment", position: 2, arm: @arm)
          vg_d = create(:visit_group, name: 'D', position: 2, day: 3, arm_id: @arm.id)

          expect(@protocols_participant.reload.appointments.count).to eq(5)
          expect(@protocols_participant.reload.appointments.where(name: "D").first.position).to eq(3)
        end

        it "should correctly place appointment for subject despite custom appointment when visit group position is updated" do 
          @protocols_participant.reload.appointments.create(name: "custom appointment", position: 2, arm: @arm)
          @vg_c.reload.update(position: 2, day: 3)

          expect(@protocols_participant.reload.appointments.count).to eq(4)
          expect(@protocols_participant.reload.appointments.where(name: "C").first.position).to eq(3)
        end
      end

      describe 'check for completed data' do
        it "should allow the appointment to be deleted if it is not completed" do
          appointment_count = @protocols_participant.reload.appointments.count
          @procedure.reload.update_attributes(status: "unstarted")
          @vg_a.reload.destroy
          expect(@protocols_participant.reload.appointments.count).to eq(appointment_count - 1)
        end

        it "should not allow the appointment to be deleted if it is completed" do
          @appointment = @protocols_participant.reload.appointments.first
          @appointment.update_attributes(completed_date: Time.current)
          expect{@vg_a.destroy}.to raise_error(ActiveRecord::ActiveRecordError)
        end

        it "should not allow the appointment to be deleted if any of it's procedures are completed" do
          expect{@vg_a.destroy}.to raise_error(ActiveRecord::ActiveRecordError)
        end
      end
    end
  end
end
