require 'rails_helper'

feature 'Identity views financial view', js: true do

  scenario 'and sees the financial view' do
    given_i_am_viewing_the_list_of_protocols
    when_i_select_the_financial_view
    then_i_should_see_the_financial_view
  end

  def given_i_am_viewing_the_list_of_protocols
    create_and_assign_protocol_to_me

    visit protocols_path
    wait_for_ajax
  end

  def when_i_select_the_financial_view
    find('.financial').click
  end

  def then_i_should_see_the_financial_view
    expect(page.body).to have_css('.financial.active', count: 1)
  end
end
