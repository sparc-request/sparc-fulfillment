module Features

  module ProtocolHelpers

    def create_protocols(count=1)
      create_list(:protocol_imported_from_sparc, count)
    end
  end
end
