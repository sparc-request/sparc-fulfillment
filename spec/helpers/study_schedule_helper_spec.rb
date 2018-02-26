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
      arm = create(:arm_with_visit_groups, name: "Arm")

      arr = helper.visits_select_options(arm).split("\n")
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
      position = 4

      #true
      current_page = 1
      expect(helper.on_current_page?(current_page, position)).to eq(true)

      #false
      current_page = 2
      expect(helper.on_current_page?(current_page, position)).to eq(false)
    end
  end
end
