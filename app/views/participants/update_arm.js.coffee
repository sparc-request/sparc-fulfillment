$("#flashes_container").html("<%= escape_javascript(render(:partial =>'shared/flash_messages')) %>");
$("#changeArmModal").modal 'hide'
refreshParticipantTables("<%= escape_javascript(@protocol.id.to_s) %>")
