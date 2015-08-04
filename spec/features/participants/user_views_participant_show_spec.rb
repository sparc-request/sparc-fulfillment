require 'rails_helper'

feature 'User views Participant show', js: true do

  scenario 'and does not have access' do
    given_i_do_not_have_access_to_a_protocol
    when_i_try_to_visit_a_participants_calendar
    then_i_should_be_redirected_to_the_home_page
  end

  scenario 'and sees the Participants attributes in the header' do
    given_i_have_access_to_a_protocol
    when_i_try_to_visit_a_participants_calendar
    then_i_should_see_the_participant_calendar
  end

  def given_i_do_not_have_access_to_a_protocol
    @protocol    = create(:protocol_imported_from_sparc)
    @participant = @protocol.participants.first
  end

  def given_i_have_access_to_a_protocol
    @protocol = create_and_assign_protocol_to_me
    @participant = @protocol.participants.first
  end

  def when_i_try_to_visit_a_participants_calendar
    visit participant_path @participant.id
  end

  def then_i_should_be_redirected_to_the_home_page
    expect(current_path).to eq root_path # gets redirected back to index
  end

  def then_i_should_see_the_participant_calendar
    expect(page).to have_css('#participant-info')
    expect(page).to have_content(@participant.full_name)
    expect(page).to have_content(@participant.mrn) unless @participant.mrn.blank?
    expect(page).to have_content(@participant.external_id) unless @participant.external_id.blank?
    expect(page).to have_content(@participant.arm.name) unless @participant.arm.blank?
    expect(page).to have_content(@participant.status)
    expect(page).to have_content(@protocol.id)
  end
end
