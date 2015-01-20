require 'rails_helper'

RSpec.describe 'Index spec', type: :feature, js: true do

  

  let!(:protocol1) { create(:protocol, status: "Complete", short_title: "Slappy") }
  let!(:protocol2) { create(:protocol, status: "Draft", short_title: "Swanson") }

  before :each do
    visit protocols_path
  end

  describe 'status select' do

    it "should filter the table by statuses" do
      visit protocols_path
      
      bootstrap_select '.selectpicker', 'Complete'
      
      sleep 2
      expect(page.body).to have_css("table#protocol-list", text: "Slappy")
      expect(page.body).to_not have_css("table#protocol-list", text: "Swanson")
    end
  end

  describe 'financial view' do

    it "should display and hide the proper columns when financial button is clicked" do
      visit protocols_path

      find('.financial').click

      sleep 2
      expect(page).to have_content('Subsidy Amount')
      expect(page).to_not have_content('Status')
    end
  end
end
