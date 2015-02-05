$("#flashes_container").html("<%= escape_javascript(render(:partial =>'application/flash')) %>");
refreshParticipantTables("<%= @protocol.id.to_s %>")
