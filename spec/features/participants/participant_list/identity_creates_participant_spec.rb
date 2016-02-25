require 'rails_helper'

feature 'User creates Participant', js: true do

  scenario 'and sees the new Participants in the list' do
    given_i_have_a_protocol_with_multiple_arms
    when_i_view_the_participant_list
    when_i_create_a_new_participant
    then_i_should_see_the_new_participant_in_the_list
  end

  context 'on a protocol with 1 arm' do
    scenario 'and sees the participant is assigned to the arm' do
      given_i_have_a_protocol_with_1_arm 
      when_i_view_the_participant_list
      when_i_create_a_new_participant
      then_they_should_have_an_assigned_arm
    end
  end

  context 'on a protocol with multiple arms' do
    scenario 'and sees the participant is not assigned to an arm' do
      given_i_have_a_protocol_with_multiple_arms
      when_i_view_the_participant_list
      when_i_create_a_new_participant
      then_they_should_not_have_an_assigned_arm
    end
  end

  def given_i_have_a_protocol_with_multiple_arms
    @protocol = create_and_assign_protocol_to_me
  end

  def given_i_have_a_protocol_with_1_arm
    given_i_have_a_protocol_with_multiple_arms
    
    @protocol.arms[1..@protocol.arms.size].each do |arm|
      arm.destroy
    end
  end

  def when_i_view_the_participant_list
    visit protocol_path(@protocol.id)
    wait_for_ajax

    click_link 'Participant List'
    wait_for_ajax
  end

  def when_i_create_a_new_participant
    find('.new-participant').click
    wait_for_ajax

    fill_in 'Last Name', with: "Dole"
    fill_in 'First Name', with: "Bob"
    fill_in 'MRN', with: "ASD123"
    fill_in 'City', with: "Town"
    bootstrap_select '#participant_state', "South Carolina"
    fill_in 'Zip Code', with: "12345"
    page.execute_script %Q{ $("#participant_date_of_birth").siblings(".input-group-addon").trigger("click") }
    page.execute_script %Q{ $("td.year:contains('0')").trigger("click") }
    page.execute_script %Q{ $("td.month:contains('Mar')").trigger("click") }
    page.execute_script %Q{ $("td.day:contains('15')").trigger("click") }
    bootstrap_select '#participant_gender', "Female"
    bootstrap_select '#participant_ethnicity', "Hispanic or Latino"
    bootstrap_select '#participant_race', "Asian"
    fill_in 'Address', with: "123 Fake Street"

    find("input[value='Save Participant']").click
    wait_for_ajax
  end

  def then_i_should_see_the_new_participant_in_the_list
    expect(page).to have_css('#flashes_container', text: 'Participant Created')
    expect(page).to have_css('table.participants tbody tr', count: 4)
  end

  def then_they_should_have_an_assigned_arm
    expect(Participant.last.arm_id).to eq(@protocol.arms.first.id)
  end

  def then_they_should_not_have_an_assigned_arm
    expect(Participant.last.arm_id).to eq(nil)
  end
end
