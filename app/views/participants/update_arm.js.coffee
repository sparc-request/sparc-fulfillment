$("#flashes_container").html("<%= escape_javascript(render(:partial =>'shared/flash_messages')) %>");
$("#changeArmModal").modal 'hide'
refreshParticipantTables("<%= @protocol.id.to_s %>")
