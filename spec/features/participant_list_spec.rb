require 'rails_helper'

RSpec.describe 'Participant List', type: :feature, js: true do

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

  it "should create a new participant" do
    participant2 = build(:participant, protocol_id: protocol1.id, first_name: 'Jack')
    click_link "Create New Participant"
    wait_for_javascript_to_finish
    expect(page).to have_css('.modal-body') # should render new participant modal

    # Fill out new participant form and save
    fill_in 'First Name', with: participant2.first_name
    fill_in 'Last Name', with: participant2.last_name
    fill_in 'MRN', with: participant2.mrn
    select participant2.status, from: 'Patient Status'
    fill_in 'Date of Birth', with: participant2.date_of_birth
    select participant2.gender, from: 'Gender'
    select participant2.ethnicity, from: 'Ethnicity'
    select participant2.race, from: 'Race'
    fill_in 'Address', with: participant2.address
    fill_in 'Phone', with: participant2.phone
    find("input[value='Save Participant']").click

    wait_until{ page.has_no_css?("input[value='Save Participant']") } #wait for modal to disappear
    expect(page).to have_content('Participant Created') #expect flash message
    expect(page).to have_content(participant2.first_name) #table should have new entry
  end

  it "should edit an existing participant" do
    click_link "Edit"
    wait_for_javascript_to_finish
    expect(page).to have_css("#participant_first_name[value='#{participant1.first_name}']") #form should appear with correct info filled in

    #Edit participant first name then save
    fill_in 'First Name', with: (participant1.first_name + 'y')
    find("input[value='Save Participant']").click

    wait_until{ page.has_no_css?("input[value='Save Participant']") } #wait for modal to disappear
    expect(page).to have_content('Participant Saved') #expect flash message
    expect(page).to have_content((participant1.first_name + 'y')) #table should have changed entry
  end

  it "should delete an existing participant" do
    expect(page).to have_content(participant1.first_name) #participant should exist
    click_link "Remove"
    wait_for_javascript_to_finish
    expect(page).to have_content('Participant Removed') #expect flash message
    expect(page).not_to have_content(participant1.first_name) #expect participant to be removed
  end

  it "should find participants using the search bar" do
    participant2 = create(:participant, protocol_id: protocol1.id, first_name: 'Jack')
    click_button "Refresh" #refresh table to accomodate new participant
    wait_for_javascript_to_finish

    find('div.search > input').set(participant2.first_name) # search for participant2
    wait_for_javascript_to_finish
    expect(page).to have_content(participant2.first_name) # should find participant2
    expect(page).not_to have_content(participant1.first_name)  # should not display participant1

    find('div.search > input').set('asdfghjkl') # search for gibberish
    wait_for_javascript_to_finish
    expect(page).to have_content('No matching records found') # should find no matching records
  end
end