$("#flashes_container").html("<%= escape_javascript(render('flash')) %>");
refreshParticipantTables("<%= @protocol.id.to_s %>")
