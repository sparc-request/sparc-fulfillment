require 'rails_helper'

feature 'Identity views protocol', js: true do

  scenario 'and sees that the Current IRB Expiration Date is correctly formatted' do
    given_i_am_a_fulfillment_provider_for_a_protocol
    when_i_visit_the_protocol_page
    then_i_should_see_a_correctly_formatted_irb_expiration_date
  end

  def given_i_am_a_fulfillment_provider_for_a_protocol
    identity          = Identity.first
    clinical_provider = create(:clinical_provider_with_organization, identity: identity)
    organization      = clinical_provider.organization
    service_request   = create(:service_request_with_protocol)
    create(:sub_service_request, organization: organization, service_request: service_request)
    @protocol         = Protocol.first
  end

  def when_i_visit_the_protocol_page
    visit protocol_path(@protocol)
  end

  def then_i_should_see_a_correctly_formatted_irb_expiration_date
    expect(page).to have_css('.irb_expiration_date', text: /\d\d\/\d\d\/\d\d/)
  end
end
