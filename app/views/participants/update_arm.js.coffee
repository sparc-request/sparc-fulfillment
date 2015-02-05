$("#flashes_container").html("<%= escape_javascript(render(:partial =>'application/flash')) %>");
$("#changeArmModal").modal 'hide'
refreshParticipantTables("<%= @protocol.id.to_s %>")
