module DataHelpers

  def create_and_assign_protocol_to_me
    identity      = Identity.first
    protocol      = create(:protocol_imported_from_sparc)
    organization  = protocol.organization

    create(:clinical_provider, identity: identity, organization: organization)
  end
end