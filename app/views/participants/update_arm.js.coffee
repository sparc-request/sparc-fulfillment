$("#flashes_container").html("<%= escape_javascript(render('flash')) %>");
$("#modal_place").modal 'hide'
refreshParticipantTables("<%= @protocol.id.to_s %>")
