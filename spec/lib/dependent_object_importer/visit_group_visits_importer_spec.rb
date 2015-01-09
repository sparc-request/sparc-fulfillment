require 'rails_helper'

RSpec.describe VisitGroupVisitsImporter do

  it 'should inherit from DependentObjectImporter' do
    visit_group                 = double('visit_group')
    visit_group_visits_importer = VisitGroupVisitsImporter.new(visit_group)

    expect(visit_group_visits_importer).to be_a(DependentObjectImporter)
    expect(visit_group_visits_importer).to respond_to(:save_and_create_dependents)
  end

  describe '#create_dependents' do

    before do
      arm                               = create(:arm_with_line_items)
      visit_group                       = build(:visit_group, arm: arm)
      @visit_group_visit_group_creator  = VisitGroupVisitsImporter.new(visit_group)

      @visit_group_visit_group_creator.save_and_create_dependents
    end

    it 'should persist the LineItem record' do
      expect(@visit_group_visit_group_creator.visit_group).to be_persisted
    end

    it 'should create and associate VisitGroups' do
      expect(@visit_group_visit_group_creator.visit_group).to have(2).visits
    end
  end
end
