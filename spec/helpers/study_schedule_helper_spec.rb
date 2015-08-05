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

      expect(helper.visits_select_options(visit_group.arm)).to eq(visits_select_options_return(visit_group.arm))
    end
  end

  describe "#build_visits_select" do
    it "should return html to render the visit select" do
      arm = create(:arm)
      page = 1
      html_return = build_visits_select_return(arm, page)
      
      expect(helper.build_visits_select(arm, page)).to eq(html_return)
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

  def visits_select_options_return arm, cur_page=1
    per_page = Visit.per_page
    visit_count = arm.visit_count
    visit_group_names = arm.visit_groups.map(&:name)
    num_pages = (visit_count / per_page.to_f).ceil
    arr = []

    num_pages.times do |page|
      beginning_visit = (page * per_page) + 1
      ending_visit = (page * per_page + per_page)
      ending_visit = ending_visit > visit_count ? visit_count : ending_visit

      option = ["Visits #{beginning_visit} - #{ending_visit} of #{visit_count}", page + 1, class: "title", :page => page + 1]
      arr << option

      (beginning_visit..ending_visit).each do |y|
        arr << ["&nbsp;&nbsp; - #{visit_group_names[y - 1]}".html_safe, "#{visit_group_names[y - 1]}", :page => page + 1]
      end
    end

    options_for_select(arr, cur_page)
  end

    def build_visits_select_return arm, page
    select_tag "visits_select_for_#{arm.id}", visits_select_options(arm, page), class: 'visit_dropdown form-control selectpicker', :'data-arm_id' => "#{arm.id}", page: page
  end
end