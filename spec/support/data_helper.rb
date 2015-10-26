module DataHelpers

  def create_and_assign_protocol_with_a_single_service
    identity              = Identity.first
    sub_service_request   = create(:sub_service_request_with_organization)
    protocol              = create(:protocol_with_single_service, sub_service_request: sub_service_request)
    organization_provider = create(:organization_provider, name: "Provider")
    organization_program  = create(:organization_program, name: "Program", parent: organization_provider)
    organization          = sub_service_request.organization
    organization.update_attributes(parent: organization_program, name: "Core")
    create(:clinical_provider, identity: identity, organization: organization)
    create(:project_role_pi, identity: identity, protocol: protocol)

    protocol
  end

  def create_and_assign_protocol_with_duplicate_services
    identity              = Identity.first
    sub_service_request   = create(:sub_service_request_with_organization)
    protocol              = create(:protocol_with_duplicate_services, sub_service_request: sub_service_request)
    organization_provider = create(:organization_provider, name: "Provider")
    organization_program  = create(:organization_program, name: "Program", parent: organization_provider)
    organization          = sub_service_request.organization
    organization.update_attributes(parent: organization_program, name: "Core")
    create(:clinical_provider, identity: identity, organization: organization)
    create(:project_role_pi, identity: identity, protocol: protocol)

    protocol
  end

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

  def create_and_assign_blank_protocol_to_me
    identity              = Identity.first
    protocol              = create(:protocol_with_sub_service_request)
    organization          = protocol.organization
    organization_provider = create(:organization_provider, name: "Provider")
    organization_program  = create(:organization_program, name: "Program", parent: organization_provider)
    organization.update_attributes(parent: organization_program, name: "Core")
    create(:clinical_provider, identity: identity, organization: organization)

    protocol
  end

  def create_and_assign_participant_to_me
    protocol = create_and_assign_protocol_to_me
    arm = create(:arm, protocol: protocol)
    create(:participant, arm: arm, protocol: protocol)
  end

  def create_and_assign_appointment_to_me
    participant = create_and_assign_participant_to_me
    create(:appointment, name: "Appointment", participant: participant, arm: participant.arm)
  end
end
