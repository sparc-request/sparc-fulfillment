require 'rails_helper'

RSpec.describe VisitGroup, type: :model do

  it { is_expected.to belong_to(:arm) }
  it { is_expected.to have_many(:visits).dependent(:destroy) }
  it { is_expected.to have_many(:line_items).through(:arm) }
  it { is_expected.to have_many(:appointments) }

  context 'validations' do
    it { is_expected.to validate_presence_of :arm_id }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :position }

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
      it "should ensure that day is greater than preceding VisitGroup's day and less than succeeding VisitGroup's day" do
        arm = Arm.create(subject_count: 1, visit_count: 1, name: "Arm1")
        [1, 2, 3].permutation.each_with_index do |days, idx|
          before_visit_group = build(:visit_group, position: 3 * (idx + 1), day: days[0], arm: arm)
          visit_group        = build(:visit_group, position: 3 * (idx + 1) + 1, day: days[1], arm: arm)
          after_visit_group  = build(:visit_group, position: 3 * (idx + 1) + 2, day: days[2], arm: arm)
          before_visit_group.save(validate: false)
          visit_group.save(validate: false)
          after_visit_group.save(validate: false)

          # if days in order, should be valid
          if days[0] < days[1] && days[1] < days[2]
            expect(visit_group).to be_valid, "#{before_visit_group.inspect}\n#{visit_group.inspect}\n#{after_visit_group.inspect}\nexpected second VisitGroup to be valid, got invalid"
          else
            expect(visit_group).not_to be_valid, "#{before_visit_group.inspect}\n#{visit_group.inspect}\n#{after_visit_group.inspect}\nexpected second VisitGroup to be invalid, got valid"
          end
        end
      end

      context "when inserting a VisitGroup" do
        it "should validate :day correctly" do
          arm = Arm.create(subject_count: 1, visit_count: 1, name: "Arm1")
          create(:visit_group, position: 1, day: 0, arm: arm)
          create(:visit_group, position: 2, day: 2, arm: arm)
          valid_vg = build(:visit_group, position: 2, day: 1, arm: arm)
          invalid_vg = build(:visit_group, position: 2, day: 2, arm: arm)

          expect(valid_vg).to be_valid
          expect(invalid_vg).not_to be_valid
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

    describe 'public' do

      it 'should return correct insertion_name' do
        vg = create(:visit_group_with_arm, name: 'some_name')
        expect(vg.insertion_name).to eq("insert before " + vg.name)
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
          @participant = create(:participant, arm: @arm, protocol: @protocol)
          @appointment = create(:appointment, visit_group: @vg_a, participant: @participant, name: @vg_a.name, arm_id: @vg_a.arm_id, position: 1)
          @procedure   = create(:procedure, :complete, appointment: @appointment)
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

      describe 'check for completed data' do
        it "should allow the appointment to be deleted if it is not completed" do
          @procedure.update_attributes(status: "unstarted")
          @vg_a.destroy
          expect(@participant.appointments.empty?).to eq(true)
        end

        it "should not allow the appointment to be deleted if it is completed" do
          @appointment.update_attributes(completed_date: Time.current)
          @vg_a.destroy
          expect(@participant.appointments.empty?).to eq(false)
        end

        it "should not allow the appointment to be deleted if any of it's procedures are completed" do
          @vg_a.destroy
          expect(@participant.appointments.empty?).to eq(false)
        end
      end
    end
  end
end
