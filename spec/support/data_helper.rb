module DataHelpers

  def create_and_assign_protocol_to_me
    identity              = Identity.first
    sub_service_request   = create(:sub_service_request_with_organization)
    protocol              = create(:protocol_imported_from_sparc, sub_service_request: sub_service_request)
    organization_provider = create(:organization_provider, name: "Provider")
    organization_program  = create(:organization_program, name: "Program", parent: organization_provider)
    organization          = sub_service_request.organization
    organization.update_attributes(parent: organization_program, name: "Core")
    FactoryGirl.create(:clinical_provider, identity: identity, organization: organization)
    FactoryGirl.create(:project_role_pi, identity: identity, protocol: protocol)

    protocol
  end

  def create_and_assign_protocol_without_services_to_me
    identity              = Identity.first
    sub_service_request   = create(:sub_service_request_with_organization)
    protocol              = create(:protocol_imported_from_sparc, :without_services, sub_service_request: sub_service_request)
    organization_provider = create(:organization_provider, name: "Provider")
    organization_program  = create(:organization_program, name: "Program", parent: organization_provider)
    organization          = sub_service_request.organization
    organization.update_attributes(parent: organization_program, name: "Core")
    FactoryGirl.create(:clinical_provider, identity: identity, organization: organization)
    FactoryGirl.create(:project_role_pi, identity: identity, protocol: protocol)

    protocol
  end

  def create_blank_protocol
    identity              = Identity.first
    protocol              = create(:protocol_with_sub_service_request)
    organization          = protocol.organization
    organization_provider = create(:organization_provider, name: "Provider")
    organization_program  = create(:organization_program, name: "Program", parent: organization_provider)
    organization.update_attributes(parent: organization_program, name: "Core")
    create(:clinical_provider, identity: identity, organization: organization)

    protocol
  end
end
