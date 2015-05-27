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

  scenario 'and sees a the Protocol even when :irb_expiration_date is NULL' do
    given_i_am_a_fulfillment_provider_for_a_protocol_whose_irb_expiration_date_is_null
    when_i_visit_the_protocols_page
    then_i_should_see_protocols_for_which_i_am_a_filfillment_provider
  end

  scenario 'and sees a the Protocols table even when :irb_approval_date is NULL' do
    given_i_am_a_fulfillment_provider_for_a_protocol_whiose_irb_approval_date_is_null
    when_i_visit_the_protocols_page
    then_i_should_see_protocols_for_which_i_am_a_filfillment_provider
  end

  def given_i_am_a_fulfillment_provider_for_a_protocol
    create_and_assign_protocol_to_me
  end

  def given_i_am_not_a_fulfillment_provider_for_a_protocol
    other_identity    = create(:identity)
    clinical_provider = create(:clinical_provider_with_organization, identity: other_identity)
    organization      = clinical_provider.organization
    service_request   = create(:service_request_with_protocol)
    create(:sub_service_request, organization: organization, service_request: service_request)
  end

  def given_i_am_a_fulfillment_provider_for_a_protocol_whose_irb_expiration_date_is_null
    create_and_assign_protocol_to_me
    protocol = Protocol.first

    protocol.update_attribute :irb_expiration_date, nil
  end

  def given_i_am_a_fulfillment_provider_for_a_protocol_whiose_irb_approval_date_is_null
    create_and_assign_protocol_to_me
    protocol = Protocol.first

    protocol.update_attribute :irb_approval_date, nil
  end

  def when_i_visit_the_protocols_page
    visit protocols_path
  end

  def and_i_click_on_the_coordinators_dropdown
    page.find('table.protocols tbody tr:first-child td.coordinators button').click
  end

  def and_a_change_is_made_to_the_protocol_by_another_identity
    Protocol.first.update_attribute :short_title, 'Test 123'
    refresh_bootstrap_table('table.protocols')
  end

  def then_i_should_see_protocols_for_which_i_am_a_filfillment_provider
    expect(page).to have_css("table.protocols tbody tr td.sparc_id", count: 1)
  end

  def then_i_should_not_see_protocols_for_which_i_am_not_a_filfillment_provider
    expect(page).to have_css("table.protocols tbody tr", text: "No matching records found")
  end

  def then_i_should_see_a_list_of_coordinators
    expect(page).to have_css('table.protocols tr:first-child td.coordinators ul.dropdown-menu')
  end

  def then_i_should_see_the_change
    expect(page).to have_css('table.protocols td.short_title', text: 'Test 123')
  end
end

