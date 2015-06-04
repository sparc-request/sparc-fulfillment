module DataHelpers

  def create_and_assign_protocol_to_me
    identity      = Identity.first
    protocol      = create(:protocol_imported_from_sparc)
    organization  = protocol.organization

    create(:clinical_provider, identity: identity, organization: organization)

    protocol
  end

  def create_blank_protocol
    identity      = Identity.first
    protocol      = create(:protocol_with_sub_service_request)
    organization  = protocol.organization

    create(:clinical_provider, identity: identity, organization: organization)

    protocol
  end
end
