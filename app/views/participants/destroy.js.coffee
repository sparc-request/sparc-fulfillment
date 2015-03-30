$("#flashes_container").html("<%= escape_javascript(render('flash')) %>");
refreshParticipantTables("<%= @protocol_id %>")
