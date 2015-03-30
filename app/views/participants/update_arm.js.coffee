$("#flashes_container").html("<%= escape_javascript(render('flash')) %>");
$("#modal_place").modal 'hide'
refreshParticipantTables("<%= @participant.protocol_id.to_s %>")
