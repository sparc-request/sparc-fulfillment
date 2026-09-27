$("#modalContainer").html("<%= j render 'edit_protocol_title_modal', protocol: @protocol, time_tracking_protocol: @time_tracking_protocol %>").modal('show')
