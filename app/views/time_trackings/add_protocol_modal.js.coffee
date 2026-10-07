$("#modalContainer").html("<%= j render 'add_protocol_modal', available_protocols: @available_protocols, selected_protocol_ids: @selected_protocol_ids %>").modal('show')
