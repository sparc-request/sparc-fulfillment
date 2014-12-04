require 'rails_helper'
RSpec.describe 'Index spec', type: :feature, js: true do
  before { visit protocols_path }

  let!(:protocol1) { create(:protocol, status: "Complete") }
  let!(:protocol2) { create(:protocol, status: "Nexus Approved") }

  describe 'status select' do

    it "should filter the table by statuses" do
      bootstrap_select '.selectpicker', 'Complete'
      expect(page).to have_content('Complete')
      expect(page).not_to have_content('Nexus Approved')
    end
  end
end
