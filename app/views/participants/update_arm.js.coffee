$("#flashes_container").html("<%= escape_javascript(render('flash')) %>");
$("#changeArmModal").modal 'hide'
refreshParticipantTables("<%= @protocol.id.to_s %>")
