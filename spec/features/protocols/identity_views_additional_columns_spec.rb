require 'rails_helper'

feature 'Identity views additional columns', js: true do

  before :each do
    create_and_assign_protocol_to_me
  end

  scenario 'user adds the provider column' do
    as_a_user_who_visits_the_protocols_index_page
    when_i_select_provider_from_the_dropdown
    i_should_see_the_provider_column
  end

  scenario 'user adds the program column' do
    as_a_user_who_visits_the_protocols_index_page
    when_i_select_program_from_the_dropdown
    i_should_see_the_program_column
  end

  scenario 'user adds the core column' do
    as_a_user_who_visits_the_protocols_index_page
    when_i_select_core_from_the_dropdown
    i_should_see_the_core_column
  end


  def as_a_user_who_visits_the_protocols_index_page
    visit protocols_path
  end

  def when_i_select_provider_from_the_dropdown
    find('.keep-open').click
    wait_for_ajax
    find("input[data-field='provider']").click
  end

  def i_should_see_the_provider_column
    wait_for_ajax
    expect(page).to have_content('Provider')
  end

  def when_i_select_program_from_the_dropdown
    find('.keep-open').click
    wait_for_ajax
    find("input[data-field='program']").click
  end

  def i_should_see_the_program_column
    wait_for_ajax
    expect(page).to have_content('Program')
  end

  def when_i_select_core_from_the_dropdown
    find('.keep-open').click
    wait_for_ajax
    find("input[data-field='core']").click
  end

  def i_should_see_the_core_column
    wait_for_ajax
    expect(page).to have_content('Core')
  end
end