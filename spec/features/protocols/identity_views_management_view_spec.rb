require 'rails_helper'

feature 'Identity views management view', js: true do

  scenario 'and sees the management view' do
    given_i_am_viewing_the_list_of_protocols
    when_i_select_the_management_view
    then_i_should_see_the_management_view
  end

  def given_i_am_viewing_the_list_of_protocols
    create_and_assign_protocol_to_me

    visit protocols_path
    wait_for_ajax
  end

  def when_i_select_the_management_view
    find('.management').click
  end

  def then_i_should_see_the_management_view
    expect(page.body).to have_css('.management.active', count: 1)
  end
end
