module Features

  module ProtocolHelpers

    def create_and_assign_protocol_to_me
      identity      = Identity.first
      protocol      = create(:protocol_imported_from_sparc)
      organization  = Organization.first

      create(:clinical_provider, identity: identity, organization: organization)
    end
  end
end
