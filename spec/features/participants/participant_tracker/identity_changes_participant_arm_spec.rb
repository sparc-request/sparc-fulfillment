require 'rails_helper'

feature 'User changes Participant Arm', js: true do

  context 'with an unassigned arm' do
    context 'on a protocol with 2+ arms' do
      scenario 'and sees a blank selection by default' do
        given_i_have_a_protocol_with_multiple_arms_and_participants_without_arms
        given_i_am_viewing_the_participant_tracker
        when_i_open_the_change_arm_modal
        then_i_should_see_nothing_selected
      end
    end

    context 'on a protocol with 1 arm' do
      scenario 'and sees the single arm selected by default' do
        given_i_have_a_protocol_with_1_arm_and_participants_without_arms
        given_i_am_viewing_the_participant_tracker
        when_i_open_the_change_arm_modal
        then_i_should_see_the_only_arm
      end
    end
  end

  context 'with an assigned arm' do
    scenario 'and sees the updated Participant' do
      given_i_have_a_normal_protocol
      given_i_am_viewing_the_participant_tracker
      when_i_change_a_participants_arm
      then_i_should_see_the_arm_is_updated
    end
  end

  def given_i_have_a_protocol_with_multiple_arms_and_participants_without_arms
    @protocol = create_and_assign_protocol_to_me
    @arm      = @protocol.arms.second

    @protocol.arms.each do |arm|
      arm.participants.each do |p|
        Participant.destroy(p.id)
      end
    end

    create(:participant, first_name: "Barack Obama", last_name: "You thought this would be Obama. Well, you were wrong.", protocol: @protocol)
  end

  def given_i_have_a_protocol_with_1_arm_and_participants_without_arms
    @protocol = create_and_assign_protocol_to_me
    @protocol.arms.each {|arm| Arm.destroy(arm.id)}
    @arm      = create(:arm, name: "ageddon", protocol: @protocol)
                create(:participant, first_name: "Barack Obama", last_name: "You thought this would be Obama. Well, you were wrong.", protocol: @protocol)
  end

  def given_i_have_a_normal_protocol
    @protocol = create_and_assign_protocol_to_me
    @arm      = @protocol.arms.second
  end

  def given_i_am_viewing_the_participant_tracker
    visit protocol_path(@protocol.id)
    wait_for_ajax

    click_link 'Participant Tracker'
  end

  def when_i_open_the_change_arm_modal
    page.find('table.participants tbody tr:first-child td.change_arm a').click
    wait_for_ajax
  end

  def when_i_change_a_participants_arm
    when_i_open_the_change_arm_modal

    bootstrap_select "#participant_arm_id", @arm.name

    click_button 'Save'
  end

  def then_i_should_see_nothing_selected
    expect(page).to have_text("Nothing selected")
  end

  def then_i_should_see_the_only_arm
    expect(page).to have_text(@arm.name)
  end

  def then_i_should_see_the_arm_is_updated
    expect(page).to have_css('#flashes_container', text: 'Participant Successfully Changed Arms')
    expect(page).to have_css('table.participants tbody tr:first-child td.arm_name', text: @arm.name)
  end
end
