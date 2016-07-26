require 'rails_helper'

feature 'Identity views Report tab', js: true, enqueue: false do
  scenario 'and sees a list of Protocol reports' do
    protocol = create_data
    visit protocol_path(protocol)
    wait_for_ajax

    click_button "study_schedule_report_#{protocol.id}"
    wait_for_ajax

    click_link 'Reports'
    wait_for_ajax

    expect(page).to have_css 'table.protocol_reports tbody td.title', count: 1
  end

  scenario 'and sees a list of Participant reports' do
    protocol = create_data
    participant = protocol.participants.first
    visit protocol_path(protocol)
    wait_for_ajax

    click_link 'Participant Tracker'
    wait_for_ajax

    click_button "participant_report_#{participant.id}"
    wait_for_ajax

    click_link 'Reports'
    wait_for_ajax

    expect(page).to have_css 'table.protocol_reports tbody td.title', count: 1
  end

  private

  def create_data
    identity = Identity.first
    sub_service_request = create(:sub_service_request_with_organization)
    protocol = create(:protocol_imported_from_sparc, sub_service_request: sub_service_request)
    organization_provider = create(:organization_provider)
    organization_program = create(:organization_program, parent: organization_provider)
    organization = sub_service_request.organization
    organization.update_attributes(parent: organization_program, name: "Core")
    create(:clinical_provider, identity: identity, organization: organization)
    create(:project_role_pi, identity: identity, protocol: protocol)
    protocol
  end
end

