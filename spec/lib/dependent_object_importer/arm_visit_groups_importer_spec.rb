require 'rails_helper'

RSpec.describe ArmVisitGroupsImporter do

  describe '#create_dependents' do

    it 'should inherit from DependentObjectImporter' do
      object                    = Object.new
      arm_visit_groups_importer = ArmVisitGroupsImporter.new(object)

      expect(arm_visit_groups_importer).to be_a(DependentObjectImporter)
      expect(arm_visit_groups_importer).to respond_to(:save_and_create_dependents)
    end

    context 'valid Arm attributes' do

      before do
        arm                       = build(:arm, visit_count: 2)
        @arm_visit_group_creator  = ArmVisitGroupsImporter.new(arm)

        @arm_visit_group_creator.save_and_create_dependents
      end

      it 'should persist the Arm record' do
        expect(@arm_visit_group_creator.arm).to be_persisted
      end

      it 'should create and associate VisitGroups' do
        expect(@arm_visit_group_creator.arm).to have(2).visit_groups
      end
    end

    context 'invalid Arm attributes' do

      it 'should raise ActiveRecord::RecordInvalid' do
        invalid_arm             = build(:arm, name: nil)
        arm_visit_group_creator = ArmVisitGroupsImporter.new(invalid_arm)

        expect{ arm_visit_group_creator.save_and_create_dependents }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
