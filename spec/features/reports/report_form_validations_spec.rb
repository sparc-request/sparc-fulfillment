require 'rails_helper'

feature 'Report form validations', js: true do

  context 'Identity submits Billing Report request form with missing date' do
    scenario 'and sees a blank start date error' do
      given_i_have_opened_the_blank_billing_report_form_modal
      when_i_click_request_report
      then_i_should_see_an_error_saying "Start date must not be blank"
    end
  end

  context 'Identity submits Billing Report request form with a missing title' do
    scenario 'and sees a blank title error' do
      given_i_have_opened_the_blank_billing_report_form_modal
      given_i_have_filled_out_the_form_without_a_title
      when_i_click_request_report
      then_i_should_see_an_error_saying "Title must not be blank"
    end
  end

  def given_i_have_opened_the_blank_billing_report_form_modal
    protocol = create_and_assign_protocol_to_me
    create(:participant, protocol: protocol)
    visit documents_path

    find("button[data-type='billing_report']").click
    wait_for_ajax
  end

  def given_i_have_filled_out_the_form_without_a_title
    fill_in "Title", with: ""
  end

  def when_i_click_request_report
    find(".modal input[type='submit']").click
    wait_for_ajax
  end

  def then_i_should_see_an_error_saying(message)
    expect(page).to have_css('#modal_errors', text: message)
  end
end
