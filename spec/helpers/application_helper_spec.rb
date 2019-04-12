# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

RSpec.describe ApplicationHelper do

  describe "#format_date" do
    it "should return a formatted date" do
      expect(helper.format_date(Date.new(2015, 8, 4))).to eq("08/04/2015")
    end
  end

  describe "#format_datetime" do
    it "should return a formatted datetime" do
      expect(helper.format_datetime(DateTime.new(2015, 8, 4, 3, 20))).to eq("2015-08-04 03:20")
    end
  end

  describe "#display_cost" do
    it "should return a dollar currency string" do
      expect(helper.display_cost(1000)).to eq("$10.00") #Included because float rounding normally will cause 1000 to show as 999.99
      expect(helper.display_cost(1025)).to eq("$10.25")
      expect(helper.display_cost(1025.1)).to eq("$10.25")
      expect(helper.display_cost(1025.9)).to eq("$10.25")
    end
  end

  describe "#hidden_class" do
    it "should return :hidden" do
      expect(helper.hidden_class(true)).to eq(:hidden)
    end
  end

  describe "#disabled_class" do
    it "should return :disabled" do
      expect(helper.disabled_class(true)).to eq(:disabled)
    end
  end

  describe "#contains_disabled_class" do
    it "should return :contains_disabled" do
      expect(helper.contains_disabled_class(true)).to eq(:contains_disabled)
    end
  end

  describe "#twitterized_type" do
    it "should return a twitter-bootstrap type" do
      expect(helper.twitterized_type("alert")).to eq("alert-danger")
      expect(helper.twitterized_type("error")).to eq("alert-danger")
      expect(helper.twitterized_type("notice")).to eq("alert-info")
      expect(helper.twitterized_type("success")).to eq("alert-success")
      expect(helper.twitterized_type("asdf")).to eq("asdf")
    end
  end

  describe "#notes_button" do
    context "no notes" do
      params = {object: Participant.create(),
                title: 'Notes',
                has_notes: false,
                button_class: ''}

      it "should return a white button with blue text" do
        expect(helper.notes_button(params)).to have_selector(".btn-default")
      end
    end

    context "has notes" do
      params = {object: Participant.create(),
                title: 'Notes',
                has_notes: true,
                button_class: ''}

      it "should return a blue button with white text" do
        expect(helper.notes_button(params)).to have_selector(".blue-glyphicon")
      end
    end
  end

  describe "#service_name_display" do
    context "active service" do
      it "should display just the service name" do
        service = create(:service, is_available: true)
        expect(helper.service_name_display(service)).to_not have_selector(".inactive-service")
        expect(helper.service_name_display(service)).to have_content(service.name)
      end
    end

    context "inactive service" do
      it "should display service name and (Inactive) label" do
        service = create(:service, is_available: false)
        expect(helper.service_name_display(service)).to have_selector(".inactive-service")
        expect(helper.service_name_display(service)).to have_content(service.name)
      end
    end
  end
end
