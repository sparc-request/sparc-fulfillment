require 'rails_helper'

RSpec.describe 'User clicks Financial/Management View buttons', type: :feature, js: true do

  before { visit protocols_path }

  describe 'initial button group state' do

    it 'should not have a selection' do
      expect(page.body).to_not have_css(".financial-management-view label.active")
    end
  end

  describe 'User clicks Management view' do

    it 'should add the .active class to the label' do
      page.find(".financial-management-view label.management").click

      expect(page.body).to have_css(".financial-management-view label.management.active")
      expect(page.body).to have_css(".financial-management-view label.active", count: 1)
    end
  end

  describe 'User switches between Financial and Management views' do

    it 'should move the .active class to the correct label' do
      page.find(".financial-management-view label.management").click
      page.find(".financial-management-view label.financial").click

      expect(page.body).to have_css(".financial-management-view label.financial.active")
      expect(page.body).to have_css(".financial-management-view label.active", count: 1)
    end
  end
end
