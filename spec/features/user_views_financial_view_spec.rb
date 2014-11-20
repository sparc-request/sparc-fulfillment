require 'rails_helper'

RSpec.describe 'User views Financial View', type: :feature do

  describe 'initial button group state', js: true do

    it 'should not have a selection' do

      visit protocols_path
      page.find(".financial-management-view label.management").click

      expect(page.body).to have_css(".financial-management-view label.management.active")
    end
  end
end
