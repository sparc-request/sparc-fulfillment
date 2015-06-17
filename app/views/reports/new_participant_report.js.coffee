$("#modal_area").html("<%= escape_javascript(render(:partial =>'new_participant_report_modal')) %>")
$("#modal_place").modal('show')
$("#participant_id").selectpicker()
