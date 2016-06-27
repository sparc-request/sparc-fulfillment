require 'rails_helper'

feature 'Identity views additional columns', js: true do

  before :each do
    create_and_assign_protocol_to_me
  end

  scenario 'user adds the organizations column' do
    as_a_user_who_visits_the_protocols_index_page
    when_i_select_organizations_from_the_dropdown
    i_should_see_the_organizations_column
  end

  def as_a_user_who_visits_the_protocols_index_page
    visit protocols_path
    wait_for_ajax
  end

  def when_i_select_organizations_from_the_dropdown
    find('.keep-open').click
    wait_for_ajax
    find("input[data-field='organizations']").click
  end

  def i_should_see_the_organizations_column
    wait_for_ajax
    expect(page).to have_content('Provider/Program/Core')
  end
end