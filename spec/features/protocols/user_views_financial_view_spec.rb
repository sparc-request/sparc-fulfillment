require 'rails_helper'

RSpec.describe 'User clicks Financial/Management View buttons', type: :feature, js: true do

  before :each do
    @protocol1      = create_and_assign_protocol_to_me
    @protocol1.update_attributes(status: "Complete", short_title: "Slappy")
    @protocol2      = create_and_assign_protocol_to_me
    @protocol2.update_attributes(status: "Draft", short_title: "Swanson")
    visit protocols_path
  end

  describe 'initial button group state' do

    it 'should not have a selection' do
      expect(page.body).to_not have_css(".financial-management-view label.active")
    end
  end

  describe 'User clicks Management view' do

    it 'should add the .active class to the label' do

      find(".management").click

      expect(page.body).to have_css(".management.active")
      expect(page.body).to have_css(".active", count: 1)
    end
  end

  describe 'User switches between Financial and Management views' do

    it 'should move the .active class to the correct label' do
      find(".management").click
      find(".financial").click

      expect(page.body).to have_css(".financial.active")
      expect(page.body).to have_css(".active", count: 1)
    end
  end
end
