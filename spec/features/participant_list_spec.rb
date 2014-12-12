require 'rails_helper'

RSpec.describe 'Participant List spec', type: :feature, js: true do

  before {
    protocol = create(:protocol)
    visit protocols_path
  }

  it "should show the index page" do
    expect(page.body).to have_css('body.protocols')
  end
end
