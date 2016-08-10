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
        expect(helper.notes_button(params)).to have_selector(".btn-primary")
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
