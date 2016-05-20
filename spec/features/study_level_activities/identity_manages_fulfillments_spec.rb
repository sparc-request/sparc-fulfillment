require 'rails_helper'

feature 'Fulfillments', js: true do

  describe 'fulfillments list' do
    it 'should list the fulfillments' do
      given_i_have_fulfillments
      and_i_have_opened_up_fulfillments
      expect(page).to have_content('Fulfillments List')
    end
  end

  describe 'fulfillment add' do
    it 'should be able to add a fulfillment' do
      given_i_have_fulfillments
      count = @line_item.fulfillments.count
      and_i_have_opened_up_fulfillments
      click_button "Add Fulfillment"
      wait_for_ajax
      when_i_fill_out_the_fulfillment_form
      expect(page).to have_content('Fulfillment Created')
    end
  end



  def given_i_have_fulfillments
    @protocol = create_and_assign_protocol_to_me
    sparc_protocol = @protocol.sparc_protocol
    sparc_protocol.update_attributes(type: 'Study')
    service     = create(:service_with_one_time_fee)
    @line_item  = create(:line_item, protocol: @protocol, service: service)
    @components = @line_item.components
    @clinical_providers = Identity.first.clinical_providers
    @fulfillment = create(:fulfillment, line_item: @line_item)
  end

  def and_i_have_opened_up_fulfillments
    given_i_have_fulfillments
    visit protocol_path(@protocol.id)
    wait_for_ajax
    click_link "Study Level Activities"
    wait_for_ajax
    first('.otf-fulfillment-list').click
    wait_for_ajax
  end

  def when_i_fill_out_the_fulfillment_form
    page.execute_script %Q{ $('#date_fulfilled_field').trigger("focus") }
    page.execute_script %Q{ $("td.day:contains('15')").trigger("click") }
    fill_in 'Quantity', with: "45"
    find('.modal-header').click
    wait_for_ajax
    click_button "Save Fulfillment"
    wait_for_ajax
  end
end
