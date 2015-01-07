require 'rails_helper'

RSpec.describe ArmVisitGroupsCreator do

  describe '#create' do

    context 'valid Arm attributes' do

      before do
        arm                       = build(:arm, visit_count: 2)
        @arm_visit_group_creator  = ArmVisitGroupsCreator.new(arm)

        @arm_visit_group_creator.create
      end

      it 'should persist the Arm record' do
        expect(@arm_visit_group_creator.arm).to be_persisted
      end

      it 'should create and associate VisitGroups' do
        expect(@arm_visit_group_creator.arm.visit_groups.count).to eq(2)
      end
    end

    context 'invalid Arm attributes' do

      it 'should raise ActiveRecord::RecordInvalid' do
        invalid_arm             = build(:arm, name: nil)
        arm_visit_group_creator = ArmVisitGroupsCreator.new(invalid_arm)

        expect{ arm_visit_group_creator.create }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
