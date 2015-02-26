require 'rails_helper'

RSpec.describe 'Index spec', type: :feature, js: true do

  let!(:protocol1) { create(:protocol_imported_from_sparc, status: "Complete", short_title: "Slappy") }
  let!(:protocol2) { create(:protocol_imported_from_sparc, status: "Draft", short_title: "Swanson") }

  before :each do
    visit protocols_path
  end

  describe 'status select' do

    it "should filter the table by statuses" do
      bootstrap_select '#index_selectpicker', 'Complete'

      wait_for_javascript_to_finish

      expect(page.body).to have_css("table#protocol-list", text: "Slappy")
      expect(page.body).to_not have_css("table#protocol-list", text: "Swanson")
    end
  end

  describe 'financial view' do

    it "should display and hide the proper columns when financial button is clicked" do
      wait_for_javascript_to_finish

      find('.financial').click

      wait_for_javascript_to_finish
      expect(page).to have_content('Subsidy Amount')
      expect(page).to_not have_content('Status')
    end
  end
end
