$("#flashes_container").html("<%= escape_javascript(render(:partial =>'shared/flash_messages')) %>");
refreshParticipantTables("<%= @protocol.id.to_s %>")
