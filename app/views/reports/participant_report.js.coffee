$("#modal_area").html("<%= escape_javascript(render(partial: 'participant_report')) %>")
$("#modal_place").modal('show')
$("#participant_id").selectpicker()

