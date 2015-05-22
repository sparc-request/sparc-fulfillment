require "rails_helper"

feature "Identity views financial view", js: true do

  scenario "and sees financial formatting" do
    given_i_am_a_fulfillment_provider_for_a_protocol
    when_i_visit_the_protocols_page
    and_i_click_on_the_financial_view_button
    then_i_should_see_financial_formatting
  end

  def given_i_am_a_fulfillment_provider_for_a_protocol
    identity          = Identity.first
    clinical_provider = create(:clinical_provider_with_organization, identity: identity)
    organization      = clinical_provider.organization
    service_request_1 = create(:service_request_with_protocol)
    service_request_2 = create(:service_request_with_protocol)
    create(:sub_service_request, organization: organization, service_request: service_request_1)
    create(:sub_service_request, organization: organization, service_request: service_request_2)

    service_request_1.protocol.update_attributes(status: "Complete", short_title: "Slappy")
    service_request_2.protocol.update_attributes(status: "Draft", short_title: "Swanson")
  end

  def when_i_visit_the_protocols_page
    visit protocols_path
  end

  def and_i_click_on_the_financial_view_button
    find('.financial').click
    wait_for_ajax
  end

  def then_i_should_see_financial_formatting
    expect(page).to have_content('Subsidy Amount')
    expect(page).to_not have_content('Status')
  end
end
