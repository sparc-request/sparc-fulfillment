require "rails_helper"

feature "Identity views protocol", js: true do

  scenario "that has no Services" do
    given_i_am_a_fulfillment_provider_for_a_protocol_without_services
    when_i_visit_the_protocol_page
    then_i_should_not_see_service_related_elements
  end

  scenario "and sees that the Current IRB Expiration Date is correctly formatted" do
    given_i_am_a_fulfillment_provider_for_a_protocol
    when_i_visit_the_protocol_page
    then_i_should_see_a_correctly_formatted_irb_expiration_date
  end

  def given_i_am_a_fulfillment_provider_for_a_protocol
    @protocol = create_and_assign_protocol_to_me
  end

  def given_i_am_a_fulfillment_provider_for_a_protocol_without_services
    @protocol = create_and_assign_protocol_without_services_to_me
  end

  def when_i_visit_the_protocol_page
    visit protocol_path(@protocol.id)
    wait_for_ajax
  end

  def then_i_should_see_a_correctly_formatted_irb_expiration_date
    expect(page).to have_css(".irb_expiration_date", text: /\d\d\/\d\d\/\d\d/)
  end

  def then_i_should_not_see_service_related_elements
    expect(page).to_not have_css("div[role='tabpanel'] a", text: "Study Schedule")
    expect(page).to_not have_css("div[role='tabpanel'] a", text: "Participant List")
    expect(page).to_not have_css("div[role='tabpanel'] a", text: "Participant Tracker")
    expect(page).to_not have_css("#study_schedule_buttons")
    expect(page).to_not have_css("#study_schedule_tabs")
  end
end
