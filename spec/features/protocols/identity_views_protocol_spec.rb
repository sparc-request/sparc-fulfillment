require 'rails_helper'

feature 'Identity views protocol', js: true do

  scenario 'and sees that the Current IRB Expiration Date is correctly formatted' do
    given_i_am_a_fulfillment_provider_for_a_protocol
    when_i_visit_the_protocol_page
    then_i_should_see_a_correctly_formatted_irb_expiration_date
  end

  def given_i_am_a_fulfillment_provider_for_a_protocol
    @protocol = create_and_assign_protocol_to_me
  end

  def when_i_visit_the_protocol_page
    visit protocol_path(@protocol.sparc_id)
  end

  def then_i_should_see_a_correctly_formatted_irb_expiration_date
    expect(page).to have_css('.irb_expiration_date', text: /\d\d\/\d\d\/\d\d/)
  end
end
