module DataHelpers

  def create_and_assign_protocol_to_me
    identity            = Identity.first
    sub_service_request = FactoryGirl.create(:sub_service_request_with_organization)
    protocol            = FactoryGirl.create(:protocol_imported_from_sparc, sub_service_request: sub_service_request)
    parent_organization = FactoryGirl.create(:organization, type: "Provider")
    organization        = sub_service_request.organization
    organization.update_attributes(parent: parent_organization)
    FactoryGirl.create(:clinical_provider, identity: identity, organization: organization)
    FactoryGirl.create(:project_role_pi, identity: identity, protocol: protocol)

    protocol
  end

  def create_and_assign_protocol_without_services_to_me
    identity            = Identity.first
    sub_service_request = FactoryGirl.create(:sub_service_request_with_organization)
    protocol            = FactoryGirl.create(:protocol_imported_from_sparc, :without_services, sub_service_request: sub_service_request)
    parent_organization = FactoryGirl.create(:organization, type: "Provider")
    organization        = sub_service_request.organization
    organization.update_attributes(parent: parent_organization)
    FactoryGirl.create(:clinical_provider, identity: identity, organization: organization)
    FactoryGirl.create(:project_role_pi, identity: identity, protocol: protocol)

    protocol
  end

  def create_blank_protocol
    identity            = Identity.first
    protocol            = create(:protocol_with_sub_service_request)
    organization        = protocol.organization
    parent_organization = FactoryGirl.create(:organization, type: "Provider")
    organization.update_attributes(parent: parent_organization)
    create(:clinical_provider, identity: identity, organization: organization)

    protocol
  end
end
