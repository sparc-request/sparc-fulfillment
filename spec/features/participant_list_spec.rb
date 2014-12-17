require 'rails_helper'

RSpec.describe 'Participant List spec', type: :feature, js: true do

  let!(:protocol1)    { create(:protocol) }
  let!(:arm1)         { create(:arm, protocol_id: protocol1.id) }
  let!(:participant1) { create(:participant, protocol_id: protocol1.id, first_name: 'Charles') }

  before :each do
    visit protocol_path(protocol1.sparc_id)
    click_link 'Participant List'
  end

  it "should find participants" do
    expect(page).to have_css('.bootstrap-table', visible: true)
    expect(page).to have_content(participant1.first_name)
  end

  it "should render new participant modal" do
    click_link "Create New Participant"
    wait_for_javascript_to_finish
    expect(page).to have_css('.modal-body')
  end

  it "should create new participant" do
    click_link "Create New Participant"
    wait_for_javascript_to_finish

    # Fill out new participant form
    fill_in 'First Name', with: 'Jack'
    fill_in 'Last Name', with: participant1.last_name
    fill_in 'MRN', with: participant1.mrn
    select participant1.status, from: 'Patient Status'
    fill_in 'Date of Birth', with: participant1.date_of_birth
    select participant1.gender, from: 'Gender'
    select participant1.ethnicity, from: 'Ethnicity'
    select participant1.race, from: 'Race'
    fill_in 'Address', with: participant1.address
    fill_in 'Phone', with: participant1.phone
    find("input[value='Save Participant']").click

    wait_until{ page.has_no_css?("input[value='Save Participant']") } #wait for modal to disappear
    expect(page).to have_content('Participant Created') #expect flash message
    click_button "Refresh" #refresh table
    wait_for_javascript_to_finish
    expect(page).to have_content('Jack') #table should have new entry
  end

  it "should edit an existing participant"
  it "should delete an existing participant"
  it "should sort participants by column"
  it "should find participants using the search bar"
end