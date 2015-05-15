require 'rails_helper'

RSpec.describe LineItemVisitsImporter do

  it 'should inherit from DependentObjectImporter' do
    line_item                 = double('line_item')
    line_item_visits_importer = LineItemVisitsImporter.new(line_item)

    expect(line_item_visits_importer).to be_a(DependentObjectImporter)
    expect(line_item_visits_importer).to respond_to(:save_and_create_dependents)
  end

  describe '#create_dependents' do

    before do
      arm                             = create(:arm_with_visit_groups, protocol: create(:protocol), visit_count: 5)
      line_item                       = build(:line_item, protocol: arm.protocol, service: create(:service), arm: arm)
      @line_item_visit_group_creator  = LineItemVisitsImporter.new(line_item)

      @line_item_visit_group_creator.save_and_create_dependents
    end

    it 'should persist the LineItem record' do
      expect(@line_item_visit_group_creator.line_item).to be_persisted
    end

    it 'should create and associate VisitGroups' do
      expect(@line_item_visit_group_creator.line_item).to have(5).visits
    end
  end
end
