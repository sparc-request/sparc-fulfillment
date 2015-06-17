require 'rails_helper'

feature 'Report form validations', js: true do

  before(:each) do
    protocol = create_and_assign_protocol_to_me
    create(:participant, protocol: protocol)
    visit documents_path
  end

  scenario 'Identity submits Billing Report request form with missing date' do
    given_that_i_have_filled_out_the_billing_report_form_with_missing_dates
    when_i_click_request_report
    i_should_see_an_error_saying("Start Date cannot be blank")
  end

  def given_that_i_have_filled_out_the_billing_report_form_with_missing_dates
    find("[data-title='billing_report']").click
    wait_for_ajax
  end

  def when_i_click_request_report
    find(".modal button.submit").click
    wait_for_ajax
  end

  def i_should_see_an_error_saying(message)
    expect(page).to have_css('#modal_errors', text: message)
  end
end
