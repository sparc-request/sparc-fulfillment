require 'rails_helper'

RSpec.describe StudyScheduleHelper do

  describe "#glyph_class" do
    it "should return a glyphicon class" do
      visit_group = create(:visit_group_with_arm)
      visits = []
      3.times do
        visits << create(:visit, visit_group: visit_group)
      end
      #glyphicon-ok class
      expect(helper.glyph_class(visit_group)).to eq("glyphicon-ok")
      
      #glyphicon-remove class
      visits.each do |visit|
        visit.update_attributes(research_billing_qty: 1)
        visit.update_attributes(insurance_billing_qty: 1)
      end

      expect(helper.glyph_class(visit_group)).to eq("glyphicon-remove")
    end
  end

  describe "#set_check" do
    it "should return whether or not to set check" do
      visit_group = create(:visit_group_with_arm)
      visits = []
      3.times do
        visits << create(:visit, visit_group: visit_group)
      end
      #false
      expect(helper.set_check(visit_group)).to eq(true)
      
      #true
      visits.each do |visit|
        visit.update_attributes(research_billing_qty: 1)
        visit.update_attributes(insurance_billing_qty: 1)
      end

      expect(helper.set_check(visit_group)).to eq(false)
    end
  end

  describe "#visits_select_options" do
    it "should return the visit options" do
      visit_group = create(:visit_group_with_arm)
      3.times do
        create(:visit, visit_group: visit_group)
      end

      arr = helper.visits_select_options(visit_group.arm).split("\n")
      arr = arr[0..8] if arr.length > 9

      expect(arr[0].include?("title"))
      expect(arr[1].include?('value="Visit Group 3"'))

      for i in 2..arr.length-1
        expect(arr[i].include?('value=""'))
      end
    end
  end

  describe "#on_current_page?" do
    it "should return whether or not a visit is on the page" do
      visit_group = create(:visit_group_with_arm)
      3.times do
        create(:visit, visit_group: visit_group)
      end
      current_page = 1

      #true
      expect(helper.on_current_page?(current_page, visit_group)).to eq(true)

      #false
      current_page = 2
      expect(helper.on_current_page?(current_page, visit_group)).to eq(false)
    end
  end
end
