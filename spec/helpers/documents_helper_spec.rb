require 'rails_helper'

RSpec.describe DocumentsHelper do
  
  describe "#format_date" do
    it "should return a formatted date" do
      expect(helper.format_date(Date.new(2015, 8, 4))).to eq("08/04/2015")
    end
  end
end
