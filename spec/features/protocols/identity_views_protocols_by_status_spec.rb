require "rails_helper"

feature "Identity views Protocols by status", js: true do

  scenario "and filters by complete Protocols" do
    given_i_am_a_fulfillment_provider_for_a_protocol
    when_i_visit_the_protocols_page
    and_i_filter_protocols_by_complete_status
    then_i_should_only_see_protocols_in_the_complete_status
  end

  def given_i_am_a_fulfillment_provider_for_a_protocol
    2.times { create_and_assign_protocol_to_me }

    Protocol.first.sub_service_request.update_attributes(status: "complete")
    Protocol.first.sparc_protocol.update_attributes(short_title: "Slappy")
    Protocol.last.sub_service_request.update_attributes(status: "draft")
    Protocol.last.sparc_protocol.update_attributes(short_title: "Swanson")
  end

  def when_i_visit_the_protocols_page
    visit protocols_path
    wait_for_ajax
  end

  def and_i_filter_protocols_by_complete_status
    bootstrap_select '#index_selectpicker', 'Complete'
    wait_for_ajax
  end

  def then_i_should_only_see_protocols_in_the_complete_status
    expect(page.body).to have_css("table#protocol-list", text: "Slappy")
    expect(page.body).to_not have_css("table#protocol-list", text: "Swanson")
  end
end
