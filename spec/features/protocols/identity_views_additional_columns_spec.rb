require 'rails_helper'

feature 'Identity views additional columns', js: true do
  let!(:identity)            { Identity.first }
  let!(:provider)            { create(:organization_provider, name: "Test Provider") }
  let!(:program)             { create(:organization_program, parent: provider, name: "Test Program") }
  let!(:core)                { create(:organization_core, parent: program, name: "Test Core") }
  let!(:sub_service_request) { create(:sub_service_request, organization: core) }
  let!(:protocol)            { create(:protocol, sub_service_request: sub_service_request) }
  let!(:clinical_provider)   { create(:clinical_provider, identity: identity, organization: core) }
  let!(:pi)                  { create(:project_role_pi, identity: identity, protocol: protocol) }

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
    expect(page).to have_content('Test Provider')
  end

  def when_i_select_program_from_the_dropdown
    find('.keep-open').click
    wait_for_ajax
    find("input[data-field='program']").click
  end

  def i_should_see_the_program_column
    wait_for_ajax
    expect(page).to have_content('Test Program')
  end

  def when_i_select_core_from_the_dropdown
    find('.keep-open').click
    wait_for_ajax
    find("input[data-field='core']").click
  end

  def i_should_see_the_core_column
    wait_for_ajax
    expect(page).to have_content('Test Core')
  end
end