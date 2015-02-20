$("#appointment_modal_place").html("<%= escape_javascript(render(:partial =>'incomplete_procedure_modal', locals: {procedure: @procedure, note: @note}))%>");
$("#appointment_modal").modal 'show'
