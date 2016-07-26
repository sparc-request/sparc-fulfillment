require 'rails_helper'

feature 'Identity views protocols', js: true do

  scenario 'and sees Protocols for which they are a Fulfillment Provider for' do
    given_i_am_a_fulfillment_provider_for_a_protocol
    when_i_visit_the_protocols_page
    then_i_should_see_protocols_for_which_i_am_a_filfillment_provider
  end

  scenario 'and does not see Protocols for which they are not a Fulfillment Provider for' do
    given_i_am_not_a_fulfillment_provider_for_a_protocol
    when_i_visit_the_protocols_page
    then_i_should_not_see_protocols_for_which_i_am_not_a_filfillment_provider
    and_i_should_not_be_able_to_access_protocols_for_which_i_am_not_a_filfillment_provider
  end

  scenario 'and sees Coordinators' do
    given_i_am_a_fulfillment_provider_for_a_protocol
    when_i_visit_the_protocols_page
    and_i_click_on_the_coordinators_dropdown
    then_i_should_see_a_list_of_coordinators
  end

  scenario 'and sees changes made by other Identitys in realtime' do
    given_i_am_a_fulfillment_provider_for_a_protocol
    when_i_visit_the_protocols_page
    and_a_change_is_made_to_the_protocol_by_another_identity
    then_i_should_see_the_change
  end

  def given_i_am_a_fulfillment_provider_for_a_protocol
    create_and_assign_protocol_to_me
  end

  def given_i_am_not_a_fulfillment_provider_for_a_protocol
    organization            = create(:organization)
    sub_service_request     = create(:sub_service_request, organization: organization)
    @unauthorized_protocol  = create(:protocol, sub_service_request: sub_service_request)
  end

  def when_i_visit_the_protocols_page
    visit protocols_path
    wait_for_ajax
  end

  def and_i_click_on_the_coordinators_dropdown
    page.find('table.protocols tbody tr:first-child td.coordinators button').click
  end

  def and_a_change_is_made_to_the_protocol_by_another_identity
    Protocol.first.sparc_protocol.update_attribute :short_title, 'Test 123'
    refresh_bootstrap_table('table.protocols')
  end

  def then_i_should_see_protocols_for_which_i_am_a_filfillment_provider
    expect(page).to have_css("table.protocols tbody tr td.short_title", count: 1)
  end

  def then_i_should_not_see_protocols_for_which_i_am_not_a_filfillment_provider
    expect(page).to have_css("table.protocols tbody tr", text: "No matching records found")
  end

  def and_i_should_not_be_able_to_access_protocols_for_which_i_am_not_a_filfillment_provider
    visit protocol_path(@unauthorized_protocol.id) # tries to visit protocol without access
    wait_for_ajax
    
    expect(current_path).to eq root_path # gets redirected back to index
  end

  def then_i_should_see_a_list_of_coordinators
    expect(page).to have_css('table.protocols tr:first-child td.coordinators ul.dropdown-menu')
  end

  def then_i_should_see_the_change
    expect(page).to have_css('table.protocols td.short_title', text: 'Test 123')
  end
end

